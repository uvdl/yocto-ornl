# Build Automation

SHELL := /bin/bash
CPUS := $(shell nproc)
SUDO := $(shell test $${EUID} -ne 0 && echo "sudo")
LANG := en_US.UTF-8
DATE := $(shell date +%Y-%m-%d_%H%M)
ARCHIVE := /opt
EPHEMERAL := /tmp

# allow for generation of working eth0
HOST := 10.223.0.1
NETMASK := 16

.EXPORT_ALL_VARIABLES:

DEV=
DOT_GZ=.gz
EULA=1	# https://patchwork.openembedded.org/patch/100815/
MACHINE=var-som-mx6-ornl
PKGDEPS1=gawk wget git-core diffstat unzip texinfo gcc-multilib \
build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
xz-utils debianutils iputils-ping libsdl1.2-dev xterm
PKGDEPS2=autoconf libtool libglib2.0-dev libarchive-dev python-git \
sed cvs subversion coreutils texi2html docbook-utils python-pysqlite2 \
help2man make gcc g++ desktop-file-utils libgl1-mesa-dev libglu1-mesa-dev \
mercurial automake groff curl lzop asciidoc u-boot-tools dos2unix mtd-utils pv \
libncurses5 libncurses5-dev libncursesw5-dev libelf-dev zlib1g-dev device-tree-compiler
PLATFORM_GIT=https://github.com/varigit/variscite-bsp-platform.git
# FIXME: requires mod to BuildScripts/ornl-setup-yocto.sh
PROJECT=yocto-ornl
PROJECT_REMOTE := $(USER)
PROJECT_TAG := core
# https://source.android.com/setup/develop#old-repo-python2
REPO=$(EPHEMERAL)/repo
REPO_LOC=https://storage.googleapis.com/git-repo-downloads/repo-1
REPO_SUM=b5caa4be6496419057c5e1b1cdff1e4bdd3c1845eec87bd89ecb2e463a3ee62c
TOASTER_PORT := 8000

# Known variations
# FIXME: requires mod to BuildScripts/ornl-setup-yocto.sh
YOCTO_VERSION=thud
YOCTO_DIR := $(EPHEMERAL)/$(PROJECT)-$(YOCTO_VERSION)
YOCTO_DISTRO=fslc-framebuffer
YOCTO_ENV=build_ornl
YOCTO_PROD=dev
YOCTO_IMG=var-$(YOCTO_PROD)-update-full-image
YOCTO_CMD := $(YOCTO_IMG)
ETH0_NETWORK=$(YOCTO_DIR)/sources/meta-ornl/recipes-core/default-eth0/files/eth0.network

# Kernel rebuilding; paths relative to $(YOCTO_DIR)/$(YOCTO_ENV)
_KERNEL_RELATIVE_PATH := tmp/work/var_som_mx6_ornl-fslc-linux-gnueabi/linux-variscite/4.9.88-r0
KERNEL_BUILD=$(_KERNEL_RELATIVE_PATH)/build
KERNEL_GIT=$(_KERNEL_RELATIVE_PATH)/git
KERNEL_IMAGE=tmp/deploy/images/$(MACHINE)/uImage
KERNEL_DTS=tmp/deploy/images/$(MACHINE)
KERNEL_TEMP=$(_KERNEL_RELATIVE_PATH)/temp

.PHONY: all archive build clean dependencies docker-deploy docker-image environment environment-update
.PHONY: id kernel kernel-config kernel-pull locale mrproper sdk see swu
.PHONY: toaster toaster-start toaster-stop

# https://stackoverflow.com/questions/10858261/how-to-abort-makefile-if-variable-not-set
# NB: EPHEMERAL is the parent folder of the yocto build and is extremely important.
#     The yoocto build folder cannot be moved, grows to ~76GB during the build and
#     toaster runs on one build folder at a time.  Getting this wrong wastes alot of time...
ifeq ($(strip $(EPHEMERAL)),)
$(error EPHEMERAL is not set)
endif
ifeq ($(strip $(EPHEMERAL)),/tmp)
$(warning *** Using EPHEMERAL=$(EPHEMERAL) ***)
endif

default: see

$(ARCHIVE):
	mkdir -p $(ARCHIVE)

$(REPO): $(shell dirname $(REPO))
	# https://github.com/curl/curl/issues/1399
	echo "$(REPO_SUM)  -" > /tmp/sum.txt && curl -fLs $(REPO_LOC) | tee $@ | sha256sum -c /tmp/sum.txt
	chmod a+x $@

$(YOCTO_DIR):
	mkdir -p $(YOCTO_DIR)

$(YOCTO_DIR)/setup-environment: $(REPO) $(YOCTO_DIR)
	cd $(YOCTO_DIR) && \
		$(REPO) init -u $(PLATFORM_GIT) -b $(YOCTO_VERSION) && \
		$(REPO) sync -j$(CPUS)
	@if [ ! -x $@ ] ; then false ; fi

environment: $(YOCTO_DIR)/setup-environment
	cd $(YOCTO_DIR) && \
		rm -rf $(YOCTO_DIR)/sources/meta-ornl && \
		cp -r $(CURDIR)/sources/meta-ornl $(YOCTO_DIR)/sources && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		mkdir -p $(YOCTO_DIR)/$(YOCTO_ENV)/conf
		@echo "$(YOCTO_DIR)/sources/poky/bitbake/bin/../../meta-poky/conf" > $(YOCTO_DIR)/$(YOCTO_ENV)/conf/templateconf.cfg

$(YOCTO_DIR)/sources/meta-ornl/recipes-core/default-eth0/files/eth0.network: Makefile
	@echo "[Match]" > $@ && \
		echo "Name=eth0" >> $@ && \
		echo "" >> $@ && \
		echo "[Network]" >> $@ && \
		echo "Address=$(HOST)/$(NETMASK)" >> $@

environment-update: $(YOCTO_DIR)/setup-environment
	@$(MAKE) --no-print-directory -B $(YOCTO_DIR)/sources/meta-ornl/recipes-core/default-eth0/files/eth0.network
	cd $(YOCTO_DIR) && \
		rm -rf $(YOCTO_DIR)/sources/meta-ornl && \
		cp -r $(CURDIR)/sources/meta-ornl $(YOCTO_DIR)/sources && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cp $(CURDIR)/build/conf/local.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/ && \
		cp $(CURDIR)/build/conf/bblayers.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/ && \
		cp $(CURDIR)/BuildScripts/mx6_install_yocto_emmc.sh $(YOCTO_DIR)/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/variscite_scripts/ && \
		bitbake-layers add-layer $(YOCTO_DIR)/sources/meta-ornl && \
		echo "*** ENVIRONMENT SETUP ***" && \
		echo "Please execute the following in your shell before giving bitbake commands:" && \
		echo "cd $(YOCTO_DIR) && MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV)"

sd.img$(DOT_GZ): $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_IMG)-$(MACHINE).wic$(DOT_GZ)
	ln -sf $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_IMG)-$(MACHINE).wic$(DOT_GZ) $@

all:
	@$(MAKE) --no-print-directory -B dependencies
	@$(MAKE) --no-print-directory -B environment
	@$(MAKE) --no-print-directory -B environment-update
	@$(MAKE) --no-print-directory -B toaster
	@$(MAKE) --no-print-directory -B toaster-start
	@$(MAKE) --no-print-directory -B YOCTO_IMG=var-$(YOCTO_PROD)-update-full-image build
	@$(MAKE) --no-print-directory -B YOCTO_IMG=var-$(YOCTO_PROD)-image-swu build
	@$(MAKE) --no-print-directory -B YOCTO_IMG=var-$(YOCTO_PROD)-update-full-image YOCTO_CMD="-c populate_sdk var-$(YOCTO_PROD)-update-full-image" build
	@$(MAKE) --no-print-directory -B YOCTO_PROD=$(YOCTO_PROD) archive

archive:
	@mkdir -p $(ARCHIVE)/$(PROJECT)-$(DATE)/dts
	@( for f in `find $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_DTS) -name "*.dtb" -print` ; do n=$$(basename $$f) ; nb=$${n%.*} ; dtc -I dtb -O dts -o $(ARCHIVE)/$(PROJECT)-$(DATE)/dts/$${nb}.dts $$f ; ( set -x && cp $$f $(ARCHIVE)/$(PROJECT)-$(DATE)/dts/$${nb}.dtb ) ; done )
	@mkdir -p $(ARCHIVE)/$(PROJECT)-$(DATE)/$(YOCTO_ENV)/tmp/deploy/images
	@rsync --links -rtp --exclude={*.wic.gz,*.manifest,*testdata*,*.ubi*,*.cfg} $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE) $(ARCHIVE)/$(PROJECT)-$(DATE)/$(YOCTO_ENV)/tmp/deploy/images/
	@mkdir -p $(ARCHIVE)/$(PROJECT)-$(DATE)/$(YOCTO_ENV)/sources/meta-variscite-fslc/scripts
	cp -r $(YOCTO_DIR)/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/variscite_scripts $(ARCHIVE)/$(PROJECT)-$(DATE)/$(YOCTO_ENV)/sources/meta-variscite-fslc/scripts
	cp BuildScripts/var-create-yocto-sdcard.sh $(ARCHIVE)/$(PROJECT)-$(DATE)/$(YOCTO_ENV)/sources/meta-variscite-fslc/scripts
	cp $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_IMAGE) $(ARCHIVE)/$(PROJECT)-$(DATE)
	tar czf $(ARCHIVE)/$(PROJECT)-$(DATE)/kernel-source.tgz -C $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/work-shared/$(MACHINE) kernel-source
	@( cd $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_GIT) && commit=$$(git log | head -1 | tr -s ' ' | cut -f2 | tr -s ' ' | cut -f2 -d' ') ; touch $(ARCHIVE)/$(PROJECT)-$(DATE)/$$commit )
	@if [ -e $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/var-$(YOCTO_PROD)-image-swu-$(MACHINE).swu ] ; then set -x ; cp $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/var-$(YOCTO_PROD)-image-swu-$(MACHINE).swu $(ARCHIVE)/$(PROJECT)-$(DATE) ; fi
	@if [ -d $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/sdk ] ; then set -x ; cp -r $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/sdk $(ARCHIVE)/$(PROJECT)-$(DATE) ; fi
	@echo "# To write image to MMC, do:" > $(ARCHIVE)/$(PROJECT)-$(DATE)/readme.txt
	@echo "DEV=/dev/sdx" >> $(ARCHIVE)/$(PROJECT)-$(DATE)/readme.txt
	@echo "$(SUDO) MACHINE=$(MACHINE) $(YOCTO_ENV)/sources/meta-variscite-fslc/scripts/var-create-yocto-sdcard.sh -a -r $(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_IMG)-$(MACHINE) \$${DEV}" >> $(ARCHIVE)/$(PROJECT)-$(DATE)/readme.txt
	@if [ -e $(ARCHIVE)/$(PROJECT)-$(DATE)/var-$(YOCTO_PROD)-image-swu-$(MACHINE).swu ] ; then echo "# load var-$(YOCTO_PROD)-image-swu-$(MACHINE).swu to port :9080" >> $(ARCHIVE)/$(PROJECT)-$(DATE)/readme.txt ; fi
	@if [ -d $(ARCHIVE)/$(PROJECT)-$(DATE)/sdk ] ; then echo "# A Cross-platform SDK is available in ./sdk" >> $(ARCHIVE)/$(PROJECT)-$(DATE)/readme.txt ; fi

build: $(YOCTO_DIR)/setup-environment build/conf/local.conf build/conf/bblayers.conf sources/meta-ornl
	cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cd $(YOCTO_DIR)/$(YOCTO_ENV) && \
			LANG=$(LANG) bitbake $(YOCTO_CMD)

clean:
	-rm -rf $(YOCTO_DIR)/sources
	-rm $(YOCTO_DIR)/$(YOCTO_ENV)/conf/local.conf
	-rm $(YOCTO_DIR)/$(YOCTO_ENV)/conf/bblayers.conf

dependencies:
	$(SUDO) apt-get update
	$(SUDO) apt-get install -y $(PKGDEPS1)
	$(SUDO) apt-get install -y $(PKGDEPS2)

Dockerfile: Makefile
	@echo "FROM ubuntu:16.04" > $@
	@echo "RUN apt-get -y update && apt-get -y upgrade" >> $@
	@echo "RUN apt-get -y install git make sudo vim" >> $@
ifeq ($(PROJECT_TAG),base)
	@echo "RUN apt-get -y install $(PKGDEPS1) && apt-get -y install $(PKGDEPS2)" >> $@
endif
	@echo "RUN apt-get -y install locales && locale-gen $(LANG) && update-locale LC ALL=$(LANG) LANG=$(LANG)" >> $@
	@echo "RUN id build 2>/dev/null || useradd --uid 1000 --create-home build" >> $@
	@echo "RUN echo \"build ALL=(ALL) NOPASSWD: ALL\" | tee -a /etc/sudoers" >> $@
	@echo "USER build" >> $@
	@echo "WORKDIR /home/build/$(PROJECT)" >> $@
	@echo "COPY . /home/build/$(PROJECT)" >> $@
	@echo "RUN sudo chown -R build:build /home/build/$(PROJECT)" >> $@
	@echo "CMD \"$(SHELL)\"" >> $@

docker-deploy: docker-image
	docker tag $(PROJECT):$(PROJECT_TAG) $(PROJECT_REMOTE)/$(PROJECT):$(PROJECT_TAG)
	docker push $(PROJECT_REMOTE)/$(PROJECT):$(PROJECT_TAG)

docker-image: Dockerfile
	docker build -t $(PROJECT):$(PROJECT_TAG) .

id:
	git config --global user.name "UVDL Developer"
	git config --global user.email "uvdl@ornl.gov"
	git config --global push.default matching
	git config --global credential.helper "cache --timeout=5400"

# https://community.nxp.com/docs/DOC-95003
# https://github.com/uvdl/yocto-ornl/issues/11#issuecomment-462969336
# Edison's email from 2019-03-15 Re: FEC driver debugging
kernel:
	-rm sd.img$(DOT_GZ)
	cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cd $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_TEMP) && \
		./run.do_compile && \
		./run.do_compile_kernelmodules && \
		echo "kernel built in $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_IMAGE)"

kernel-config:
	cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cd $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_TEMP) && \
		LANG=$(LANG) bitbake linux-variscite -c menuconfig

kernel-pull:
	cd $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_GIT) && git pull

locale:
	# https://wiki.yoctoproject.org/wiki/TipsAndTricks/ResolvingLocaleIssues
	$(SUDO) apt-get install locales
	#$(SUDO) dpkg-reconfigure locales
	$(SUDO) locale-gen $(LANG)
	$(SUDO) update-locale LC ALL=$(LANG) LANG=$(LANG)

mrproper: clean toaster-stop
	-rm -rf $(YOCTO_DIR)

sd: $(YOCTO_DIR)/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_IMG)
	@if ! [ -z "$(DEV)" ] ; then cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		$(SUDO) MACHINE=$(MACHINE) $(YOCTO_DIR)/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh -a -r $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_IMG) $(DEV) ; \
	else \
		echo "Please provide a DEV; make DEV=/dev/sdb sd" && false ; \
	fi

sdk:
	@$(MAKE) --no-print-directory -B environment-update
	@$(MAKE) --no-print-directory -B build
	@$(MAKE) --no-print-directory -B YOCTO_IMG=var-$(YOCTO_PROD)-update-full-image YOCTO_CMD="-c populate_sdk var-$(YOCTO_PROD)-update-full-image" build
	@$(MAKE) --no-print-directory -B YOCTO_PROD=$(YOCTO_PROD) archive

see:
	@echo "CPUS=$(CPUS)"
	@echo "SUDO=$(SUDO)"
	@echo "YOCTO_DIR=$(YOCTO_DIR)"
	@echo "ARCHIVE-TO=$(ARCHIVE)/$(PROJECT)-$(DATE)"
	@echo "ETH0_NETWORK=$(shell grep Address $(ETH0_NETWORK))"
	@echo -n "KERNEL=$(YOCTO_DIR)/$(YOCTO_ENV)/tmp/work-shared/$(MACHINE)/kernel-source: "
	@( cd $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_GIT) && commit=$$(git log | head -1 | tr -s ' ' | cut -f2 | tr -s ' ' | cut -f2 -d' ') ; echo $$commit ) 
	-@echo "*** local.conf ***" && diff build/conf/local.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/local.conf
	-@echo "*** bblayers.conf ***" && diff build/conf/bblayers.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/bblayers.conf
	@echo "*** Build Commands ***"
	@echo "cd $(YOCTO_DIR)"
	@echo "MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV)"
	@echo "cd $(YOCTO_DIR)/$(YOCTO_ENV) && LANG=$(LANG) bitbake $(YOCTO_CMD)"
	@echo "**********************"
	@echo "Use: \"make toaster\" to install it so it can track the build (port $(TOASTER_PORT))"
	@echo "Use: \"make all\" to perform this build"

swu:
	@$(MAKE) --no-print-directory -B environment-update
	@$(MAKE) --no-print-directory -B build
	@$(MAKE) --no-print-directory -B YOCTO_IMG=var-$(YOCTO_PROD)-image-swu build
	@$(MAKE) --no-print-directory -B YOCTO_PROD=$(YOCTO_PROD) archive

toaster: $(YOCTO_DIR)/setup-environment
	# https://www.yoctoproject.org/docs/latest/toaster-manual/toaster-manual.html#toaster-manual-start
	cd $(YOCTO_DIR) && \
		rm -rf $(YOCTO_DIR)/sources/meta-ornl && \
		cp -r $(CURDIR)/sources/meta-ornl $(YOCTO_DIR)/sources && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cd $(YOCTO_DIR)/sources/poky && \
			pip3 install --user -r bitbake/toaster-requirements.txt && \
			touch $(YOCTO_DIR)/$(YOCTO_ENV)/.toaster

toaster-start: $(YOCTO_DIR)/setup-environment
	@if [ -e $(YOCTO_DIR)/$(YOCTO_ENV)/.toaster ] ; then cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		( cd $(YOCTO_DIR)/$(YOCTO_ENV) ; source toaster stop ; sleep 5 ; source toaster webport=0.0.0.0:$(TOASTER_PORT) start ) ; true ; fi

toaster-stop:
	@if [ -e $(YOCTO_DIR)/$(YOCTO_ENV)/.toaster ] ; then cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		( cd $(YOCTO_DIR)/$(YOCTO_ENV) ; source toaster stop ) ; true ; fi
