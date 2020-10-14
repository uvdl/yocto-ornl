# Automation for instructions
# https://github.com/uvdl/yocto-ornl/tree/develop

SHELL := /bin/bash
CPUS := $(shell nproc)
SUDO := $(shell test $${EUID} -ne 0 && echo "sudo")
LANG := en_US.UTF-8
DATE := $(shell date +%Y-%m-%d_%H%M)
ARCHIVE := /opt
.EXPORT_ALL_VARIABLES:

DEV=
DOT_GZ=.gz
EULA=1	# https://patchwork.openembedded.org/patch/100815/
LOGDIR=$(HOME)/log
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
PLATFORM_BRANCH=sumo
PROJECT=yocto-ornl
PROJECT_REMOTE := $(USER)
PROJECT_TAG := core
REPO=/usr/local/bin/repo
REPO_LOC=https://storage.googleapis.com/git-repo-downloads/repo
# repo version 2.8
REPO_SUM=d73f3885d717c1dc89eba0563433cec787486a0089b9b04b4e8c56e7c07c7610
TOASTER_PORT := 8000

# Known variations
YOCTO_DIR := $(HOME)/ornl-dart-yocto
YOCTO_DISTRO=fslc-framebuffer
YOCTO_ENV=build_ornl
YOCTO_IMG=var-dev-update-full-image
YOCTO_CMD := $(YOCTO_IMG)

# Kernel rebuilding; paths relative to $(YOCTO_DIR)/$(YOCTO_ENV)
_KERNEL_RELATIVE_PATH := tmp/work/var_som_mx6_ornl-fslc-linux-gnueabi/linux-variscite/4.9.88-r0
KERNEL_BUILD=$(_KERNEL_RELATIVE_PATH)/build
KERNEL_GIT=$(_KERNEL_RELATIVE_PATH)/git
KERNEL_IMAGE=tmp/deploy/images/$(MACHINE)/uImage
KERNEL_DTS=tmp/deploy/images/$(MACHINE)
KERNEL_TEMP=$(_KERNEL_RELATIVE_PATH)/temp

# https://stackoverflow.com/questions/16488581/looking-for-well-logged-make-output
# Invoke this with $(call LOG,<cmdline>)
define LOG
  @echo "$$(date --iso-8601='ns'): $1 started. ($(YOCTO_DIR)/$(YOCTO_ENV))" >>$(LOGDIR)/$(YOCTO_ENV)-make.log
  ($1) 2>&1 | tee -a $(LOGDIR)/$(YOCTO_ENV)-build.log && echo "$$(date --iso-8601='ns'): $1 completed." >>$(LOGDIR)/$(YOCTO_ENV)-make.log
endef

.PHONY: all archive build clean dependencies docker-deploy docker-image environment environment-update
.PHONY: id kernel kernel-config kernel-pull locale mrproper see
.PHONY: toaster toaster-stop

default: see

$(ARCHIVE):
	mkdir -p $(ARCHIVE)

$(LOGDIR):
	mkdir -p $(LOGDIR)

$(REPO): $(shell dirname $(REPO))
	# https://github.com/curl/curl/issues/1399
	echo "$(REPO_SUM)  -" > /tmp/sum.txt && curl -fLs $(REPO_LOC) | $(SUDO) tee $@ | sha256sum -c /tmp/sum.txt
	$(SUDO) chmod a+x $@

$(YOCTO_DIR):
	mkdir -p $(YOCTO_DIR)

$(YOCTO_DIR)/setup-environment: $(REPO) $(YOCTO_DIR)
	cd $(YOCTO_DIR) && \
		$(REPO) init -u $(PLATFORM_GIT) -b $(PLATFORM_BRANCH) && \
		$(REPO) sync -j$(CPUS)

$(YOCTO_DIR)/$(YOCTO_ENV)/conf:
	mkdir -p $(YOCTO_DIR)/$(YOCTO_ENV)/conf

environment: $(YOCTO_DIR)/$(YOCTO_ENV)/conf
	-rm $(YOCTO_DIR)/$(YOCTO_ENV)/conf/sanity.conf
	cd $(YOCTO_DIR) && \
		rm -rf $(YOCTO_DIR)/sources/meta-ornl && \
		cp -r $(CURDIR)/sources/meta-ornl $(YOCTO_DIR)/sources && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cp $(CURDIR)/build/conf/local.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/ && \
		cp $(CURDIR)/build/conf/bblayers.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/ && \
		touch $(YOCTO_DIR)/$(YOCTO_ENV)/conf/sanity.conf && \
		echo "*** ENVIRONMENT SETUP ***" && \
		echo "Please execute the following in your shell before giving bitbake commands:" && \
		echo "cd $(YOCTO_DIR) && MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV)"

environment-update: $(YOCTO_DIR)/$(YOCTO_ENV)/conf
	-rm $(YOCTO_DIR)/$(YOCTO_ENV)/conf/sanity.conf
	cd $(YOCTO_DIR) && \
		rm -rf $(YOCTO_DIR)/sources/meta-ornl && \
		cp -r $(CURDIR)/sources/meta-ornl $(YOCTO_DIR)/sources && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cp $(CURDIR)/build/conf/local.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/ && \
		cp $(CURDIR)/build/conf/bblayers.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/ && \
		bitbake-layers add-layer $(YOCTO_DIR)/sources/meta-ornl && \
		touch $(YOCTO_DIR)/$(YOCTO_ENV)/conf/sanity.conf && \
		echo "*** ENVIRONMENT SETUP ***" && \
		echo "Please execute the following in your shell before giving bitbake commands:" && \
		echo "cd $(YOCTO_DIR) && MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV)"

sd.img$(DOT_GZ): $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_IMG)-$(MACHINE).wic$(DOT_GZ)
	ln -sf $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_IMG)-$(MACHINE).wic$(DOT_GZ) $@

all: $(LOGDIR)
	$(call LOG, $(MAKE) dependencies )
	$(call LOG, $(MAKE) see )
	$(call LOG, $(MAKE) environment )
	#$(call LOG, $(MAKE) build )
	#$(call LOG, $(MAKE) sd.img$(DOT_GZ) )

archive:
	@mkdir -p $(ARCHIVE)/$(PROJECT)-$(DATE)/dts
	( for f in `find $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_DTS) -name "*.dtb" -print` ; do n=$$(basename $$f) ; nb=$${n%.*} ; dtc -I dtb -O dts -o $(ARCHIVE)/$(PROJECT)-$(DATE)/dts/$${nb}.dts $$f ; cp $$f $(ARCHIVE)/$(PROJECT)-$(DATE)/dts/$${nb}.dtb ; done )
	@mkdir -p $(ARCHIVE)/$(PROJECT)-$(DATE)/$(YOCTO_ENV)/tmp/deploy/images
	@cp -r $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE) $(ARCHIVE)/$(PROJECT)-$(DATE)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)
	@mkdir -p $(ARCHIVE)/$(PROJECT)-$(DATE)/$(YOCTO_ENV)/sources/meta-variscite-fslc/scripts
	@cp -r $(YOCTO_DIR)/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard $(ARCHIVE)/$(PROJECT)-$(DATE)/$(YOCTO_ENV)/sources/meta-variscite-fslc/scripts
	@cp BuildScripts/var-create-yocto-sdcard.sh $(ARCHIVE)/$(PROJECT)-$(DATE)/$(YOCTO_ENV)/sources/meta-variscite-fslc/scripts
	cp $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_IMAGE) $(ARCHIVE)/$(PROJECT)-$(DATE)
	tar czf $(ARCHIVE)/$(PROJECT)-$(DATE)/kernel-source.tgz -C $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/work-shared/$(MACHINE) kernel-source
	@( cd $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_GIT) && commit=$$(git log | head -1 | tr -s ' ' | cut -f2 | tr -s ' ' | cut -f2 -d' ') ; touch $(ARCHIVE)/$(PROJECT)-$(DATE)/$$commit )
	@echo "# To write image to MMC, do:" > $(ARCHIVE)/$(PROJECT)-$(DATE)/readme.txt
	@echo "DEV=/dev/sdx" >> $(ARCHIVE)/$(PROJECT)-$(DATE)/readme.txt
	@echo "$(SUDO) MACHINE=$(MACHINE) $(YOCTO_ENV)/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh -a -r $(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_CMD)-$(MACHINE) \$${DEV}" >> $(ARCHIVE)/$(PROJECT)-$(DATE)/readme.txt

build: $(YOCTO_DIR)/setup-environment build/conf/local.conf build/conf/bblayers.conf sources/meta-ornl
	@$(MAKE) --no-print-directory -B environment
	cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cd $(YOCTO_DIR)/$(YOCTO_ENV) && \
			if [ -e .toaster ] ; then source toaster stop ; source toaster start ; /bin/true ; fi && \
			LANG=$(LANG) bitbake $(YOCTO_CMD)

clean:
	-rm -f $(LOGDIR)/*-build.log $(LOGDIR)/*-make.log
	-rm sd.img$(DOT_GZ)
	-rm -rf $(YOCTO_DIR)/sources
	-rm $(YOCTO_DIR)/$(YOCTO_ENV)/conf/local.conf
	-rm $(YOCTO_DIR)/$(YOCTO_ENV)/conf/bblayers.conf
	-rm $(YOCTO_DIR)/$(YOCTO_ENV)/conf/sanity.conf

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
kernel: $(LOGDIR)
	-rm sd.img$(DOT_GZ)
	cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cd $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_TEMP) && \
		./run.do_compile && \
		./run.do_compile_kernelmodules && \
		echo "kernel built in $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_IMAGE)"

kernel-config: $(LOGDIR)
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

sd: $(YOCTO_DIR)/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_CMD)
	@if ! [ -z "$(DEV)" ] ; then cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		$(SUDO) MACHINE=$(MACHINE) $(YOCTO_DIR)/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh -a -r $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_CMD) $(DEV) ; \
	else \
		echo "Please provide a DEV; make DEV=/dev/sdb sd" && false ; \
	fi

see:
	@echo "CPUS=$(CPUS)"
	@echo "SUDO=$(SUDO)"
	@echo "YOCTO_DIR=$(YOCTO_DIR)"
	@echo "ARCHIVE-TO=$(ARCHIVE)/$(PROJECT)-$(DATE)"
	@echo "DEV=\$${DEV}1"
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

toaster: $(YOCTO_DIR)/setup-environment
	# https://www.yoctoproject.org/docs/latest/toaster-manual/toaster-manual.html#toaster-manual-start
	cd $(YOCTO_DIR) && \
		rm -rf $(YOCTO_DIR)/sources/meta-ornl && \
		cp -r $(CURDIR)/sources/meta-ornl $(YOCTO_DIR)/sources && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cd $(YOCTO_DIR)/sources/poky && \
			pip3 install --user -r bitbake/toaster-requirements.txt && \
			touch $(YOCTO_DIR)/$(YOCTO_ENV)/.toaster

toaster-stop:
	-cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cd $(YOCTO_DIR)/$(YOCTO_ENV) && \
			source toaster stop && ( rm .toaster ; /bin/true )
