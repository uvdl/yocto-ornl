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
DEFAULT_NETWORK_FILE := 10-eth0.network

.EXPORT_ALL_VARIABLES:

DEV=
DOT_GZ=.gz
EULA=1	# https://patchwork.openembedded.org/patch/100815/
# var-som-mx6-ornl, raspberrypi4-64, jetson-xavier-nx-devkit
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
REPO_LOC=https://storage.googleapis.com/git-repo-downloads/repo-2.14
REPO_SUM=b74fda4aa5df31b88248a0c562691cb943a9c45cc9dd909d000f0e3cc265b685

# Known variations
# FIXME: requires mod to BuildScripts/ornl-setup-yocto.sh
YOCTO_ENV=build_ornl
YOCTO_PROD=dev
ifeq ($(strip $(MACHINE)),var-som-mx6-ornl)
MACHINE_FOLDER=variscite
YOCTO_VERSION=dunfell
YOCTO_DISTRO=fslc-framebuffer
YOCTO_IMG=var-$(YOCTO_PROD)-update-full-image
YOCTO_DIR := $(EPHEMERAL)/$(PROJECT)-$(YOCTO_VERSION)
else ifeq ($(strip $(MACHINE)),raspberrypi4-64)
MACHINE_FOLDER=raspberrypi
YOCTO_VERSION=gatesgarth
YOCTO_DISTRO=ornl-rpi
YOCTO_IMG=raspberrypi-$(YOCTO_PROD)-full-image
YOCTO_DIR := $(EPHEMERAL)/$(PROJECT)-$(YOCTO_VERSION)
else ifeq ($(strip $(MACHINE)),jetson-xavier-nx-devkit)
MACHINE_FOLDER=jetson
YOCTO_VERSION=dunfell
YOCTO_DISTRO=ornl-tegra
YOCTO_IMG=jetson-$(YOCTO_PROD)-full-image
YOCTO_DIR := $(EPHEMERAL)/$(PROJECT)-$(YOCTO_VERSION)
endif
ETH0_NETWORK=$(YOCTO_DIR)/ornl-layers/meta-ornl/recipes-core/default-eth0/files/$(DEFAULT_NETWORK_FILE)
YOCTO_CMD := $(YOCTO_IMG)

# Kernel rebuilding; depends on kernel version, a path in $(YOCTO_DIR)/$(YOCTO_ENV) with dynamic folder names (see find calls below)
ifeq ($(strip $(YOCTO_VERSION)),thud)
KERNEL_VER=4.9.88
else
KERNEL_VER=5.4.85
endif
KERNEL_SOURCE=$(YOCTO_DIR)/$(YOCTO_ENV)/tmp/work-shared/$(MACHINE)/kernel-source
KERNEL_IMAGE=tmp/deploy/images/$(MACHINE)/uImage
KERNEL_DTS=tmp/deploy/images/$(MACHINE)

# mfgtest.sh needs adjustment to default pinghost
MFGTEST_SH=ornl-layers/meta-ornl/recipes-ornl/mfgtest/mfgtest/$(MACHINE)/mfgtest.sh
PINGHOST := $(shell echo $(HOST) | awk 'BEGIN{FS=OFS="."}{$$4=2}1')

.PHONY: all archive build clean dependencies docker-deploy docker-image environment
.PHONY: id kernel kernel-config kernel-pull locale mrproper sd sdk see swu
.PHONY: toaster toaster-stop

# https://stackoverflow.com/questions/10858261/how-to-abort-makefile-if-variable-not-set
# NB: EPHEMERAL is the parent folder of the yocto build and is extremely important.
#     The yoocto build folder cannot be moved, grows to ~76GB during the build and
#     toaster runs on one build folder at a time.  Getting this wrong wastes alot of time...
ifeq ($(strip $(EPHEMERAL)),)
$(error EPHEMERAL is not set)
else ifeq ($(strip $(EPHEMERAL)),/tmp)
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

%/$(DEFAULT_NETWORK_FILE):
	@echo "[Match]" > $@ && \
		echo "Name=eth0" >> $@ && \
		echo "" >> $@ && \
		echo "[Network]" >> $@ && \
		echo "Address=$(HOST)/$(NETMASK)" >> $@

# https://unix.stackexchange.com/questions/329083/how-to-replace-the-last-octet-of-a-valid-network-address-with-the-number-2
# but this works better: https://stackoverflow.com/a/40125775
%/mfgtest.sh:
	@mkdir -p $(shell dirname $@)
	cat sources/meta-ornl/recipes-ornl/mfgtest/mfgtest/$(MACHINE)/mfgtest.sh | sed -e 's/10.223.0.2/$(PINGHOST)/g' > $@
	@chmod a+x $@

# var-$(YOCTO_PROD)-update-full-image has a bug in some post-build stage that gives a fault exit code
# var-$(YOCTO_PROD)-image-swu doesn't exist anymore, only var-image-swu (?)
all:
	@$(MAKE) --no-print-directory -B dependencies
	@$(MAKE) --no-print-directory -B environment
	@$(MAKE) --no-print-directory -B toaster-stop
	@$(MAKE) --no-print-directory -B YOCTO_CMD="-c clean var-$(YOCTO_PROD)-update-full-image" build
	-@$(MAKE) --no-print-directory -B YOCTO_CMD=var-$(YOCTO_PROD)-update-full-image build
	@$(MAKE) --no-print-directory -B YOCTO_CMD="-c clean var-image-swu" build
	@$(MAKE) --no-print-directory -B YOCTO_CMD=var-image-swu build
	#@$(MAKE) --no-print-directory -B YOCTO_CMD="-c populate_sdk var-$(YOCTO_PROD)-update-full-image" build
	@$(MAKE) --no-print-directory -B YOCTO_PROD=$(YOCTO_PROD) archive

archive:
	BuildScripts/ornl-create-archive.sh -p $(YOCTO_PROD) -m $(MACHINE) -ip $(HOST) -nm $(NETMASK) $(YOCTO_DIR)

build:
	BuildScripts/ornl-bitbake.sh -m $(MACHINE) -d $(YOCTO_DIR) -e $(YOCTO_ENV) $(YOCTO_CMD)

# NB: need to run toaster-stop before wiping folders
# want to not fail if that is not setup/running, so have to use submake with
# needed pass-thrus of variables.
clean:
	-@$(MAKE) --no-print-directory MACHINE=$(MACHINE) YOCTO_DIR=$(YOCTO_DIR) YOCTO_ENV=$(YOCTO_ENV) toaster-stop
	BuildScripts/ornl-bitbake.sh -m $(MACHINE) -d $(YOCTO_DIR) -e $(YOCTO_ENV) "-c clean u-boot-variscite"
	BuildScripts/ornl-bitbake.sh -m $(MACHINE) -d $(YOCTO_DIR) -e $(YOCTO_ENV) "-c clean var-$(YOCTO_PROD)-update-full-image"
	BuildScripts/ornl-bitbake.sh -m $(MACHINE) -d $(YOCTO_DIR) -e $(YOCTO_ENV) "-c clean linux-variscite"
	-rm -rf $(YOCTO_DIR)/sources
	-rm -rf $(YOCTO_DIR)/ornl-layers
	-rm -rf $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)
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
ifeq ($(strip $(PROJECT_TAG)),base)
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

environment: $(YOCTO_DIR)/setup-environment
	BuildScripts/ornl-setup-yocto.sh -m $(MACHINE) -v $(YOCTO_VERSION) $(YOCTO_DIR)
	@$(MAKE) --no-print-directory -B HOST=$(HOST) NETMASK=$(NETMASK) $(ETH0_NETWORK)
	@$(MAKE) --no-print-directory -B HOST=$(HOST) $(YOCTO_DIR)/$(MFGTEST_SH)

id:
	git config --global user.name "UVDL Developer"
	git config --global user.email "uvdl@ornl.gov"
	git config --global push.default matching
	git config --global credential.helper "cache --timeout=5400"

# https://community.nxp.com/docs/DOC-95003
# https://github.com/uvdl/yocto-ornl/issues/11#issuecomment-462969336
# Edison's email from 2019-03-15 Re: FEC driver debugging
kernel:
ifeq ($(strip $(MACHINE)),var-som-mx6-ornl)
	cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		kernel=$(shell find $(YOCTO_DIR)/$(YOCTO_ENV) -type d -name "$(KERNEL_VER)*-r0" -print | head -1) && \
		cd $${kernel}/temp && \
		./run.do_compile && \
		./run.do_compile_kernelmodules && \
		echo "kernel built in $(YOCTO_DIR)/$(YOCTO_ENV)/$(KERNEL_IMAGE)"
else
	echo "kernel build for $(MACHINE) is not defined" && false
endif

kernel-config:
ifeq ($(strip $(MACHINE)),var-som-mx6-ornl)
	cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		kernel=$(shell find $(YOCTO_DIR)/$(YOCTO_ENV) -type d -name "$(KERNEL_VER)*-r0" -print | head -1) && \
		cd $${kernel}/temp && \
		LANG=$(LANG) bitbake linux-variscite -c menuconfig
else
	echo "kernel config for $(MACHINE) is not defined" && false
endif

kernel-pull:
	@( cd $(KERNEL_SOURCE) && git pull )

locale:
	# https://wiki.yoctoproject.org/wiki/TipsAndTricks/ResolvingLocaleIssues
	$(SUDO) apt-get install locales
	#$(SUDO) dpkg-reconfigure locales
	$(SUDO) locale-gen $(LANG)
	$(SUDO) update-locale LC ALL=$(LANG) LANG=$(LANG)

mrproper: clean toaster-stop
	-rm -rf $(YOCTO_DIR)

sd:
ifeq ($(strip $(MACHINE)),var-som-mx6-ornl)
	@file $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_IMG)
	@file $(YOCTO_DIR)/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh
	@if [ ! -z "$(DEV)" ] ; then cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		$(SUDO) MACHINE=$(MACHINE) $(YOCTO_DIR)/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh -a -r $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_IMG) $(DEV) ; \
	else \
		echo "Please provide a DEV; make DEV=/dev/sdb sd" && false ; \
	fi
else
	echo "SD card write for $(MACHINE) is not defined" && false
endif

# var-$(YOCTO_PROD)-update-full-image has a bug in some post-build stage that gives a fault exit code
sdk:
	@$(MAKE) --no-print-directory -B environment
	-@$(MAKE) --no-print-directory -B YOCTO_CMD=var-$(YOCTO_PROD)-update-full-image build
	@$(MAKE) --no-print-directory -B YOCTO_CMD="-c populate_sdk var-$(YOCTO_PROD)-update-full-image" build
	@$(MAKE) --no-print-directory -B YOCTO_PROD=$(YOCTO_PROD) archive

see:
	@echo "CPUS=$(CPUS)"
	@echo "SUDO=$(SUDO)"
	@echo "YOCTO_DIR=$(YOCTO_DIR)"
	@echo "ARCHIVE-TO=$(ARCHIVE)/$(PROJECT)-$(DATE)"
	@echo "ETH0_NETWORK=$(shell grep Address $(ETH0_NETWORK))"
	@echo -n "KERNEL_SOURCE=$(KERNEL_SOURCE): "
	@( cd $(KERNEL_SOURCE) && commit=$$(git log | head -1 | tr -s ' ' | cut -f2 | tr -s ' ' | cut -f2 -d' ') ; echo $$commit )
	-@echo "*** local.conf ***" && diff build/conf/$(MACHINE_FOLDER)/local.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/local.conf
	-@echo "*** bblayers.conf ***" && diff build/conf/$(MACHINE_FOLDER)/bblayers.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/bblayers.conf
	@echo "*** Build Commands ***"
	@echo "cd $(YOCTO_DIR)"
	@echo "MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV)"
	@echo "cd $(YOCTO_DIR)/$(YOCTO_ENV) && LANG=$(LANG) bitbake $(YOCTO_CMD)"
	@echo "**********************"
	@echo "Use: \"make toaster\" to install it so it can track every build"
	@echo "Use: \"make all\" to perform this build"

# var-$(YOCTO_PROD)-update-full-image has a bug in some post-build stage that gives a fault exit code
# var-$(YOCTO_PROD)-image-swu doesn't exist anymore, only var-image-swu (?)
swu:
	@$(MAKE) --no-print-directory -B environment
	# FIXME: it should not be necessary to ignore the exit status on the next command
	-@$(MAKE) --no-print-directory -B YOCTO_CMD=var-$(YOCTO_PROD)-update-full-image build
	# FIXME: it should be this @$(MAKE) --no-print-directory -B YOCTO_IMG=var-$(YOCTO_PROD)-image-swu build
	@$(MAKE) --no-print-directory -B YOCTO_CMD=var-image-swu build
	@$(MAKE) --no-print-directory -B YOCTO_PROD=$(YOCTO_PROD) archive

toaster:
	BuildScripts/ornl-bitbake.sh -m $(MACHINE) -d $(YOCTO_DIR) -e $(YOCTO_ENV) toaster enable

old-toaster:
	@$(MAKE) --no-print-directory -B environment
	# https://www.yoctoproject.org/docs/latest/toaster-manual/toaster-manual.html#toaster-manual-start
	cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cd $(YOCTO_DIR)/sources/poky && \
			pip3 install --user -r bitbake/toaster-requirements.txt && \
			touch $(YOCTO_DIR)/$(YOCTO_ENV)/.toaster

toaster-stop:
	BuildScripts/ornl-bitbake.sh -m $(MACHINE) -d $(YOCTO_DIR) -e $(YOCTO_ENV) toaster stop

old-toaster-stop:
	@if [ -e $(YOCTO_DIR)/$(YOCTO_ENV)/.toaster ] ; then cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		( cd $(YOCTO_DIR)/$(YOCTO_ENV) ; source toaster stop ) ; true ; fi
