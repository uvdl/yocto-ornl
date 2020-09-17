# UVDL Yocto Install Guide

## Option1

### Installing required packages

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

### Downloading Yocto Sumo

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

### Download ORNL layer

<pre>
$YOCTO_DIR$ git clone https://github.com/uvdl/yocto-ornl.git
$YOCTO_DIR$ cd yocto-ornl
$YOCTO_DIR/ornl$ git checkout feature/yocto_sumo
$YOCTO_DIR/ornl$ cd ..
$YOCTO_DIR$ cp -r yocto-ornl/sources/meta-ornl sources
</pre>

### Set-up Yocto build environment

<pre>
$YOCTO_DIR$ MACHINE=var-som-mx6-ornl DISTRO=fslc-framebuffer . setup-environment build_ornl
</pre>

### Build Yocto

- Before building the project, overwrite the configuration files

<pre>
$YOCTO_DIR/build_ornl$ cd ..
$YOCTO_DIR$ cp yocto-ornl/build/conf/local.conf build_ornl/conf/
$YOCTO_DIR$ cp yocto-ornl/build/conf/bblayers.conf build_ornl/conf/
</pre>

### Finally, start the build

<pre>
$YOCTO_DIR/build_fb$ cd build_ornl
$YOCTO_DIR/build_fb$ bitbake ornl-image-gui
</pre>

## Option 2

This option takes advantage of the ornl setup script. There are three different ways to use it.

### Full Setup with default yocto-ornl branch

This option will install all the dependencies needed, clone and pull all needed repos, and make the build directory for you.  All you need to do is
run the following command : 

<pre>
. ornl-setup-yocto.sh [path_to_new_build_directory] [version_of_yocto]
</pre>

*path_to_new_build_directory* - this is simply the path that you wish to have the new build directory located, i.e. /home/user/Workspace
*version_of_yocto* - the only versions of Yocto that are supported currently are sumo and thud.

Default branch is develop

### Full Setup with User defined yocto-ornl branch

This option will do the same as the previous but will the option to define what branch of the ORNL Yocto layer you want. All you need to do is
run the following command : 

<pre>
. ornl-setup-yocto.sh -c [user_def_branch] [path_to_new_build_directory] [version_of_yocto]
</pre>

*user_def_branch* - This is the branch that you wish the script to checkout when a new version of uvdl/yocto-ornl is cloned
The last two arguments are the exact same as before.

### Run just the setup-environment script

This will **NOT** go through the entire setup prcoess.  This can be thought of as just a wrapper for the setup-environment script that you have to
run in order to run bitbake.  This will **ALSO** copy the local.conf and bblayers.conf files into the build directory.  

<pre>
. ornl-setup-yocto.sh -b [path_to_build_directory]
</pre>

This assumes the build directory has already been created.  Just pass the path to the build directory and it *should* be happy.

### Finally, start the build

This step remains the same for both options.

<pre>
$YOCTO_DIR/build_fb$ cd build_ornl
$YOCTO_DIR/build_fb$ bitbake ornl-image-gui
</pre>

# Create an SDcard

**Option 1**

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

**Option 2**

Use the var-create-yocto-sdcard.sh script that is supplied by Variscite under the meta-variscite-fslc layer.  We have a companion script that can be run from this directory, use the following command. This will **ONLY** copy the Variscite script to the new directory.  From there just follow the directions from the (Variscite Build Guide)[https://variwiki.com/index.php?title=Yocto_Build_Release&release=RELEASE_SUMO_V1.2_VAR-SOM-MX6#Create_an_extended_SD_card]

<pre>
./create-sd-card.sh < Yocto_Build_Directory_Path >
</pre>

***NOTES***
- The Yocto Path needs to be the full path.

When using the Variscite script use the -a **AND** -r options. The following command should be used : 

<pre>
sudo MACHINE=var-som-mx6-ornl sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh -a -r build_ornl/tmp/deploy/images/var-som-mx6-ornl/PackageName /dev/xxx
</pre>

xxx - is the device name. Example /dev/sdb
PackageName - This is this name of the tar that is created from bitbake. Look in the tmp/images/MACHINE/ file if you are unsure.

## Flash SD To eMMC

This **ONLY** works if ***Option 2*** was chosen from the Create SD Card section.  Once the board has booted up run the install_yocto.sh script located in /usr/bin and follow the instructions.