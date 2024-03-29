# Build Automation

SHELL := /bin/bash
CPUS := $(shell nproc)
SUDO := $(shell test $${EUID} -ne 0 && echo "sudo")
LANG := en_US.UTF-8
DATE := $(shell date +%Y-%m-%d_%H%M)

# These are defaults and may be used if desired. Just
# uncomment to use them. Normally, you should set your work
# environemnt up for whatever build you want to achieve, i.e. exports. However,
# please DO NOT check them in to github with these variables set.
#
#USER=twaddle
#MACHINE=jetson-nano-devkit
#EPHEMERAL=/ephemeral/$(USER)/$(MACHINE)
#YOCTO_PROD=dev
#ARCHIVE=/data/share/build-archives/$(MACHINE)/
#S3=s3://yocto.downloads/$(MACHINE)


# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = $(strip $(foreach 1,$1, $(if $(value $1),, $(error Undefined $1 $(if $(strip $(value 2)),, $(strip $(value 2)))))))

$(call check_defined, MACHINE, The platform to build - pix-c3 imx6ul-var-dart raspberrypi4-64 or jetson-*platform*-devkit )
$(call check_defined, ARCHIVE, Where to put output files after the build)
$(call check_defined, EPHEMERAL, The parent directory of the build folder)
$(call check_defined, YOCTO_PROD, The image version - dev prod or min)
$(call check_defined, USER, The user for the build directory)

# NB: EPHEMERAL is the parent folder of the yocto build and is extremely important.
#     The yocto build folder cannot be moved, grows to ~76GB during the build and
#     toaster runs on one build folder at a time.  Getting this wrong wastes alot of time...

# allow for generation of working eth0
HOST := 10.223.0.1
NETMASK := 16
DEFAULT_NETWORK_FILE := 10-eth0.network

# NB: we are exporting all variables because otherwise a variscite build will go interactive on the EULA acceptance, etc.
.EXPORT_ALL_VARIABLES:

DEV=
DOT_GZ=.gz
EULA=1	# https://patchwork.openembedded.org/patch/100815/
# pix-c3, raspberrypi4-64, jetson-xavier-nx-devkit, imx6ul-var-dart
PKGDEPS1=gawk wget git-core diffstat unzip texinfo gcc-multilib \
build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
xz-utils debianutils iputils-ping libsdl1.2-dev xterm
PKGDEPS2=autoconf libtool libglib2.0-dev libarchive-dev python-git \
sed cvs subversion coreutils texi2html docbook-utils python-pysqlite2 \
help2man make gcc g++ desktop-file-utils libgl1-mesa-dev libglu1-mesa-dev \
mercurial automake groff curl lzop asciidoc u-boot-tools dos2unix mtd-utils pv \
libncurses5 libncurses5-dev libncursesw5-dev libelf-dev zlib1g-dev device-tree-compiler

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
ifeq ($(strip $(MACHINE)),pix-c3)
MACHINE_FOLDER=pix-c3
YOCTO_VERSION=dunfell
YOCTO_DISTRO=fslc-framebuffer
YOCTO_IMG=pixc-$(YOCTO_PROD)-update-full-image
YOCTO_DIR := $(EPHEMERAL)/$(PROJECT)-$(YOCTO_VERSION)
ARCHIVE_DIR=$(ARCHIVE)/var-$(DATE)
else ifeq ($(strip $(MACHINE)),imx6ul-var-dart)
MACHINE_FOLDER=imx6ul-var-dart
YOCTO_VERSION=dunfell
YOCTO_DISTRO=fslc-framebuffer
YOCTO_IMG=var-$(YOCTO_PROD)-update-full-image
YOCTO_DIR := $(EPHEMERAL)/$(PROJECT)-$(YOCTO_VERSION)
ARCHIVE_DIR=$(ARCHIVE)/var-$(DATE)
else ifneq (,$(findstring raspberrypi, $(MACHINE)))
MACHINE_FOLDER=raspberrypi
YOCTO_VERSION=dunfell
YOCTO_DISTRO=ornl-rpi
YOCTO_IMG=raspberrypi-$(YOCTO_PROD)-full-image
YOCTO_DIR := $(EPHEMERAL)/$(PROJECT)-$(YOCTO_VERSION)
ARCHIVE_DIR=$(ARCHIVE)/rpi-$(DATE)
else ifneq (,$(findstring jetson, $(MACHINE)))
MACHINE_FOLDER=jetson
YOCTO_VERSION=dunfell
YOCTO_DISTRO=ornl-tegra
YOCTO_IMG=tegra-$(YOCTO_PROD)-full-image
YOCTO_DIR := $(EPHEMERAL)/$(PROJECT)-$(YOCTO_VERSION)
ARCHIVE_DIR=$(ARCHIVE)/tegra-$(DATE)
else ifeq ($(strip $(MACHINE)),ts7180)
MACHINE_FOLDER=ts7180
YOCTO_VERSION=dunfell
YOCTO_DISTRO=ornl-ts
YOCTO_IMG=ts-$(YOCTO_PROD)-full-image
YOCTO_DIR := $(EPHEMERAL)/$(PROJECT)-$(YOCTO_VERSION)
ARCHIVE_DIR=$(ARCHIVE)/ts-$(DATE)
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

default: see

$(ARCHIVE):
	mkdir -p $(ARCHIVE)

$(REPO): $(shell dirname $(REPO))
	# https://github.com/curl/curl/issues/1399
	echo "$(REPO_SUM)  -" > /tmp/sum.txt && curl -fLs $(REPO_LOC) | tee $@ | sha256sum -c /tmp/sum.txt
	chmod a+x $@

$(YOCTO_DIR):
	mkdir -p $(YOCTO_DIR)

ifeq ($(strip $(MACHINE)),pix-c3)
$(YOCTO_DIR)/setup-environment: $(REPO) $(YOCTO_DIR)
	cd $(YOCTO_DIR) && \
		$(REPO) init -u https://github.com/varigit/variscite-bsp-platform.git -b $(YOCTO_VERSION) && \
		$(REPO) sync -j$(CPUS)
	@if [ ! -x $@ ] ; then false ; fi
else ifeq ($(strip $(MACHINE)),imx6ul-var-dart)
$(YOCTO_DIR)/setup-environment: $(REPO) $(YOCTO_DIR)
	cd $(YOCTO_DIR) && \
		$(REPO) init -u https://github.com/varigit/variscite-bsp-platform.git -b $(YOCTO_VERSION) && \
		$(REPO) sync -j$(CPUS)
	@if [ ! -x $@ ] ; then false ; fi
endif

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
	@$(MAKE) --no-print-directory -B YOCTO_CMD="-c clean var-$(YOCTO_PROD)-update-full-image" build
	-@$(MAKE) --no-print-directory -B YOCTO_CMD=var-$(YOCTO_PROD)-update-full-image build
	@$(MAKE) --no-print-directory -B YOCTO_CMD="-c clean var-$(YOCTO_PROD)-image-swu" build
	@$(MAKE) --no-print-directory -B YOCTO_CMD=var-$(YOCTO_PROD)-image-swu build
	#@$(MAKE) --no-print-directory -B YOCTO_CMD="-c populate_sdk var-$(YOCTO_PROD)-update-full-image" build
	@$(MAKE) --no-print-directory -B YOCTO_PROD=$(YOCTO_PROD) archive

archive:
	@echo $(ARCHIVE_DIR)
ifeq ($(S3), n)
	@mkdir -p $(ARCHIVE_DIR) && \
		BuildScripts/ornl-create-archive.sh -p $(YOCTO_PROD) -m $(MACHINE) -ip auto -nm auto -o $(ARCHIVE_DIR) $(YOCTO_DIR)
else
	@mkdir -p $(ARCHIVE_DIR) && \
		BuildScripts/ornl-create-archive.sh -p $(YOCTO_PROD) -m $(MACHINE) -ip auto -nm auto -o $(ARCHIVE_DIR) -s $(S3) $(YOCTO_DIR)
endif

build:
	BuildScripts/ornl-bitbake.sh -m $(MACHINE) -d $(YOCTO_DIR) -e $(YOCTO_ENV) $(YOCTO_CMD)

# NB: need to run toaster-stop before wiping folders
# want to not fail if that is not setup/running, so have to use submake with
# needed pass-thrus of variables.
clean:
	-@$(MAKE) --no-print-directory MACHINE=$(MACHINE) YOCTO_DIR=$(YOCTO_DIR) YOCTO_ENV=$(YOCTO_ENV) toaster-stop
	-BuildScripts/ornl-bitbake.sh -m $(MACHINE) -d $(YOCTO_DIR) -e $(YOCTO_ENV) "-c clean u-boot-variscite"
	-BuildScripts/ornl-bitbake.sh -m $(MACHINE) -d $(YOCTO_DIR) -e $(YOCTO_ENV) "-c clean var-$(YOCTO_PROD)-update-full-image"
	-BuildScripts/ornl-bitbake.sh -m $(MACHINE) -d $(YOCTO_DIR) -e $(YOCTO_ENV) "-c clean linux-variscite"
	-rm -rf $(YOCTO_DIR)/sources
	-rm -rf $(YOCTO_DIR)/ornl-layers
	-rm -rf $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)
	-rm $(YOCTO_DIR)/$(YOCTO_ENV)/conf/local.conf
	-rm $(YOCTO_DIR)/$(YOCTO_ENV)/conf/bblayers.conf

dependencies:
	$(SUDO) apt-get update
	$(SUDO) apt-get install -y $(PKGDEPS1)
	$(SUDO) apt-get install -y $(PKGDEPS2)
ifeq ($(strip $(MACHINE)),pix-c3)
	@$(MAKE) --no-print-directory -B YOCTO_VERSION=$(YOCTO_VERSION) $(YOCTO_DIR)/setup-environment
else ifeq ($(strip $(MACHINE)),imx6ul-var-dart)
	@$(MAKE) --no-print-directory -B YOCTO_VERSION=$(YOCTO_VERSION) $(YOCTO_DIR)/setup-environment
endif

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

environment:
	BuildScripts/ornl-setup-yocto.sh -m $(MACHINE) -v $(YOCTO_VERSION) $(YOCTO_DIR)
	@$(MAKE) --no-print-directory -B HOST=$(HOST) NETMASK=$(NETMASK) $(ETH0_NETWORK)
ifeq ($(strip $(MACHINE)),pix-c3)
	@$(MAKE) --no-print-directory -B HOST=$(HOST) $(YOCTO_DIR)/$(MFGTEST_SH)
endif

id:
	git config --global user.name "UVDL Developer"
	git config --global user.email "uvdl@ornl.gov"
	git config --global push.default matching
	git config --global credential.helper "cache --timeout=5400"

# https://community.nxp.com/docs/DOC-95003
# https://github.com/uvdl/yocto-ornl/issues/11#issuecomment-462969336
# Edison's email from 2019-03-15 Re: FEC driver debugging
kernel:
ifeq ($(strip $(MACHINE)),pix-c3)
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
ifeq ($(strip $(MACHINE)),pix-c3)
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
ifeq ($(strip $(MACHINE)),pix-c3)
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
	@echo "YOCTO_IMG=$(YOCTO_IMG)"
	@echo "ARCHIVE-TO=$(ARCHIVE)/$(PROJECT)-$(DATE)"
	@echo "ETH0_NETWORK.$(shell grep Address $(ETH0_NETWORK))"
	@echo -n "KERNEL_SOURCE=$(KERNEL_SOURCE): "
	@( cd $(KERNEL_SOURCE) && commit=$$(git log | head -1 | tr -s ' ' | cut -f2 | tr -s ' ' | cut -f2 -d' ') ; echo $$commit )
	-@echo "*** local.conf ***" && ( diff build/conf/$(MACHINE_FOLDER)/local.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/local.conf ; true )
	-@echo "*** bblayers.conf ***" && ( diff build/conf/$(MACHINE_FOLDER)/bblayers.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/bblayers.conf ; true )
ifeq ($(strip $(MACHINE)),pix-c3)
	@echo "*** Build Commands for $(MACHINE) ***"
	@echo "cd $(YOCTO_DIR)"
	@echo "MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV)"
	@echo "cd $(YOCTO_DIR)/$(YOCTO_ENV) && LANG=$(LANG) bitbake $(YOCTO_CMD)"
	@echo "**********************"
endif
	@echo "Use: \"make toaster\" to install it so it can track every build"
	@echo "Use: \"make all\" to perform this build"

# var-$(YOCTO_PROD)-update-full-image has a bug in some post-build stage that gives a fault exit code
# var-$(YOCTO_PROD)-image-swu doesn't exist anymore, only var-image-swu (?)
swu:
	@$(MAKE) --no-print-directory -B environment
	# NB: making the swu auto-builds the image
	@$(MAKE) --no-print-directory -B YOCTO_PROD=$(YOCTO_PROD) YOCTO_CMD="-c clean var-$(YOCTO_PROD)-image-swu" build
	@$(MAKE) --no-print-directory -B YOCTO_PROD=$(YOCTO_PROD) YOCTO_CMD=var-$(YOCTO_PROD)-image-swu build
	@$(MAKE) --no-print-directory -B YOCTO_PROD=$(YOCTO_PROD) archive

toaster:
ifeq ($(strip $(MACHINE)),pix-c3)
	@$(MAKE) --no-print-directory YOCTO_VERSION=$(YOCTO_VERSION) $(YOCTO_DIR)/setup-environment
endif
	BuildScripts/ornl-bitbake.sh -m $(MACHINE) -d $(YOCTO_DIR) -e $(YOCTO_ENV) toaster enable

toaster-stop:
	BuildScripts/ornl-bitbake.sh -m $(MACHINE) -d $(YOCTO_DIR) -e $(YOCTO_ENV) toaster stop

clean-recipe:
	RECIPE=
ifeq ($(strip $(MACHINE)),pix-c3)
	@cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cd $(YOCTO_DIR)/$(YOCTO_ENV) && \
		bitbake -c cleanall $(RECIPE)
else ifeq ($(strip $(MACHINE)),imx6ul-var-dart)
	@cd $(YOCTO_DIR) && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cd $(YOCTO_DIR)/$(YOCTO_ENV) && \
		bitbake -c cleanall $(RECIPE)
else ifneq (,$(findstring raspberrypi, $(MACHINE)))
	@cd $(YOCTO_DIR) && \
		source ${YOCTO_DIR}/ornl-yocto-rpi/layers/poky/oe-init-build-env ${YOCTO_ENV} && \
		cd $(YOCTO_DIR)/$(YOCTO_ENV) && \
		bitbake -c cleanall $(RECIPE)
else ifneq (,$(findstring jetson, $(MACHINE)))
	@cd $(YOCTO_DIR) && \
		source ${YOCTO_DIR}/ornl-yocto-tegra/setup-env --machine ${MACHINE} --distro ornl-tegra ${YOCTO_ENV} && \
		cd $(YOCTO_DIR)/$(YOCTO_ENV) && \
		bitbake -c cleanall $(RECIPE)
else ifeq ($(strip $(MACHINE)),ts7180)
	@cd $(YOCTO_DIR) && \
		. ornl-yocto-ts/layers/poky/oe-init-build-env build_ornl/  && \
		bitbake -c cleanall $(RECIPE)
endif


