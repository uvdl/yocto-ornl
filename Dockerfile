FROM ubuntu:16.04
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install git make sudo vim
RUN apt-get -y install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm
RUN apt-get -y install autoconf libtool libglib2.0-dev libarchive-dev python-git sed cvs subversion coreutils texi2html docbook-utils python-pysqlite2 help2man make gcc g++ desktop-file-utils libgl1-mesa-dev libglu1-mesa-dev mercurial automake groff curl lzop asciidoc u-boot-tools dos2unix mtd-utils pv libncurses5 libncurses5-dev libncursesw5-dev libelf-dev zlib1g-dev device-tree-compiler
RUN apt-get -y install locales && locale-gen en_US.UTF-8 && update-locale LC ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN id build 2>/dev/null || useradd --uid 1000 --create-home build
RUN echo "build ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers
USER build
WORKDIR /home/build/yocto-ornl
COPY . /home/build/yocto-ornl
RUN sudo chown -R build:build /home/build/yocto-ornl
CMD /bin/bash
