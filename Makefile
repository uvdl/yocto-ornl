# Automation for instructions
# https://github.com/uvdl/yocto-ornl/blob/develop/README.md

SHELL := /bin/bash
CPUS := $(shell nproc)
SUDO := $(shell test $${EUID} -ne 0 && echo "sudo")
LANG := en_US.UTF-8
.EXPORT_ALL_VARIABLES:

DOT_GZ=
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
# repo version 1.23
REPO_SUM=e147f0392686c40cfd7d5e6f332c6ee74c4eab4d24e2694b3b0a0c037bf51dc5

# Known variations
YOCTO_DIR=$(HOME)/ornl-dart-yocto
YOCTO_DISTRO=fslc-framebuffer
YOCTO_ENV=build_ornl
YOCTO_IMG=ornl-image-gui

# https://stackoverflow.com/questions/16488581/looking-for-well-logged-make-output
# Invoke this with $(call LOG,<cmdline>)
define LOG
  @echo "$$(date --iso-8601='ns'): $1 started. ($(YOCTO_DIR)/$(YOCTO_ENV))" >>$(LOGDIR)/$(YOCTO_ENV)-make.log
  ($1) 2>&1 | tee -a $(LOGDIR)/$(YOCTO_ENV)-build.log && echo "$$(date --iso-8601='ns'): $1 completed." >>$(LOGDIR)/$(YOCTO_ENV)-make.log
endef

.PHONY: all build clean deps docker-deploy docker-image id locale see

default: see

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

sd.img$(DOT_GZ): $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_IMG)-$(MACHINE).wic$(DOT_GZ)
	ln -s $(YOCTO_DIR)/$(YOCTO_ENV)/tmp/deploy/images/$(MACHINE)/$(YOCTO_IMG)-$(MACHINE).wic$(DOT_GZ) $@

all: $(LOGDIR)
	$(call LOG, $(MAKE) deps )
	$(call LOG, $(MAKE) see )
	$(call LOG, $(MAKE) build )
	$(call LOG, $(MAKE) sd.img$(DOT_GZ) )

build: $(YOCTO_DIR)/setup-environment build/conf/local.conf build/conf/bblayers.conf sources/meta-ornl
	# https://github.com/gmacario/easy-build/tree/master/build-yocto#bitbake-complains-if-run-as-root
	cd $(YOCTO_DIR) && \
		cp -r $(CURDIR)/sources/meta-ornl $(YOCTO_DIR)/sources && \
		MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV) && \
		cp $(CURDIR)/build/conf/local.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/ && \
		cp $(CURDIR)/build/conf/bblayers.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/ && \
		touch $(YOCTO_DIR)/$(YOCTO_ENV)/conf/sanity.conf && \
		cd $(YOCTO_DIR)/$(YOCTO_ENV) && LANG=$(LANG) bitbake $(YOCTO_IMG)

clean:
	-rm -f $(LOGDIR)/*-build.log $(LOGDIR)/*-make.log
	rm sd.img$(DOT_GZ)

deps:
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

locale:
	# https://wiki.yoctoproject.org/wiki/TipsAndTricks/ResolvingLocaleIssues
	$(SUDO) apt-get install locales
	#$(SUDO) dpkg-reconfigure locales
	$(SUDO) locale-gen $(LANG)
	$(SUDO) update-locale LC ALL=$(LANG) LANG=$(LANG)

see:
	@echo "CPUS=$(CPUS)"
	@echo "SUDO=$(SUDO)"
	@echo "YOCTO_DIR=$(YOCTO_DIR)"
	-@echo "*** local.conf ***" && diff build/conf/local.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/local.conf
	-@echo "*** bblayers.conf ***" && diff build/conf/bblayers.conf $(YOCTO_DIR)/$(YOCTO_ENV)/conf/bblayers.conf
	@echo "*** Build Commands ***"
	@echo "cd $(YOCTO_DIR)"
	@echo "MACHINE=$(MACHINE) DISTRO=$(YOCTO_DISTRO) EULA=$(EULA) . setup-environment $(YOCTO_ENV)"
	@echo "cd $(YOCTO_DIR)/$(YOCTO_ENV) && LANG=$(LANG) bitbake $(YOCTO_IMG)"
	@echo "**********************"
	@echo "Use: \"make all\" to perform this build"
