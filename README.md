# Installing required packages

Please make sure your host PC is running Ubuntu 16.04 64-bit and install the following packages:

<pre>
sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib \
build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
xz-utils debianutils iputils-ping libsdl1.2-dev xterm

sudo apt-get install autoconf libtool libglib2.0-dev libarchive-dev python-git \
sed cvs subversion coreutils texi2html docbook-utils python-pysqlite2 \
help2man make gcc g++ desktop-file-utils libgl1-mesa-dev libglu1-mesa-dev \
mercurial automake groff curl lzop asciidoc u-boot-tools dos2unix mtd-utils pv \
libncurses5 libncurses5-dev libncursesw5-dev libelf-dev zlib1g-dev
</pre>

# Downloading Yocto Sumo

- Configure your git global configuration settings (important in order to push changes to repo)

<pre>
git config --global user.name "Your Name"
git config --global user.email "Your Email"
</pre>

- Download and install repo tool (/home/$USER/bin is the preferred path)

<pre>
mkdir ~/bin
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
export PATH=~/bin:$PATH
</pre>

- Create and populate Yocto working directory (the path to the directory can be adjusted as required)

<pre>
YOCTO_DIR=ornl-dart-yocto
</pre>

<pre>
mkdir ~/$YOCTO_DIR
cd ~/$YOCTO_DIR
$YOCTO_DIR$ repo init -u https://github.com/varigit/variscite-bsp-platform.git -b sumo
$YOCTO_DIR$ repo sync -j4
</pre>

# Download ORNL layer

<pre>
$YOCTO_DIR$ git clone https://github.com/uvdl/yocto-ornl.git
$YOCTO_DIR$ cd yocto-ornl
$YOCTO_DIR/ornl$ git checkout feature/yocto_sumo
$YOCTO_DIR/ornl$ cd ..
$YOCTO_DIR$ cp -r yocto-ornl/sources/meta-ornl sources
</pre>

# Set-up Yocto build environment

<pre>
$YOCTO_DIR$ MACHINE=var-som-mx6-ornl DISTRO=fslc-framebuffer . setup-environment build_ornl
</pre>

# Build Yocto

- Before building the project, overwrite the configuration files

<pre>
$YOCTO_DIR/build_ornl$ cd ..
$YOCTO_DIR$ cp yocto-ornl/build/conf/local.conf build_ornl/conf/
$YOCTO_DIR$ cp yocto-ornl/build/conf/bblayers.conf build_ornl/conf/
</pre>

# Finally, start the build

<pre>
$YOCTO_DIR/build_fb$ cd build_ornl
$YOCTO_DIR/build_fb$ bitbake ornl-image-gui
</pre>

# Create an SDcard

A bootable SDcard image is going to be created under: **tmp/deploy/images/var-som-mx6-ornl/ornl-image-gui-var-som-mx6-ornl.wic.gz**. In order to install it:

1. Uncompress the image:

<pre>
gzip -d ornl-image-gui-var-som-mx6-ornl.wic.gz
</pre>

2. Create your sdcard

To create the SDcard, **bmaptool** is used, if you don't have it installed you can run:

<pre>
sudo apt-get install bmap-tools
</pre>

Then, create your SDcard with:

<pre>
sudo bmaptool copy ornl-image-gui-var-som-mx6-ornl.wic /dev/sdX --nobmap
</pre>