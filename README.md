# ORNL Yocto repository for DART-MX6 board

## Gettings started with Yocto's Pyro Release

### Installing required packages
```
$ sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib \
build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
xz-utils debianutils iputils-ping libsdl1.2-dev xterm

$ sudo apt-get install autoconf libtool libglib2.0-dev libarchive-dev python-git \
xterm sed cvs subversion coreutils texi2html docbook-utils python-pysqlite2 \
help2man make gcc g++ desktop-file-utils libgl1-mesa-dev libglu1-mesa-dev \
mercurial automake groff curl lzop asciidoc u-boot-tools dos2unix mtd-utils pv \
libncurses5 libncurses5-dev libncursesw5-dev libelf-dev device-tree-compiler
```

### Downloading Yocto Pyro
* Configure your git global configuration settings (important in order to push changes to repo)
```
$ git config --global user.name "Your Name"
$ git config --global user.email "Your Email"
```

* Download and install repo tool (/home/$USER/bin is the preferred path)
```
$ mkdir ~/bin
$ curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo
$ export PATH=~/bin:$PATH
```

* Create and populate Yocto working directory (the path to the directory can be adjusted as required)
```
YOCTO_DIR=ornl-dart-yocto

$ mkdir ~/$YOCTO_DIR
$ cd ~/$YOCTO_DIR
$YOCTO_DIR$ repo init -u https://github.com/varigit/variscite-bsp-platform.git -b pyro
$YOCTO_DIR$ repo sync -j4
```

#### Download ORNL layer
```
$YOCTO_DIR$ git clone https://github.com/uvdl/yocto-ornl.git
$YOCTO_DIR$ cd yocto-ornl
$YOCTO_DIR/ornl$ git checkout develop
$YOCTO_DIR/ornl$ cd ..
$YOCTO_DIR$ cp -r yocto-ornl/sources/meta-ornl sources
```


### Set-up Yocto build environment

```
$YOCTO_DIR$ MACHINE=var-som-mx6-ornl DISTRO=fslc-framebuffer . setup-environment build_ornl
```

### Build Yocto
* Before building the project, overwrite the configuration files
```
$YOCTO_DIR/build_ornl$ cd ..
$YOCTO_DIR$ cp yocto-ornl/build/conf/local.conf build_ornl/conf/
$YOCTO_DIR$ cp yocto-ornl/build/conf/bblayers.conf build_ornl/conf/
```

* Finally, start the build
```
$YOCTO_DIR/build_fb$ cd build_ornl
$YOCTO_DIR/build_fb$ bitbake fsl-image-ornl
```

### Creating SD card

Once the build process finishes, the sdcard image will be located at
**build_ornl/tmp/deploy/images/var-som-mx6-ornl/fsl-image-ornl-var-som-mx6-ornl.sdcard**. In order to 
install your sdcar you can use dd as follows:

```
sudo dd if=build_ornl/tmp/deploy/images/var-som-mx6-ornl/fsl-image-ornl-var-som-mx6-ornl.sdcard of=<your sdcard device> bs=1M
```