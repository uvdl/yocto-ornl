# UVDL Yocto Install Guide

## Fully Automatic Method

This option takes advantage of Makefile automation.

<pre>
make dependencies
make build
make archive
</pre>

This will produce a set of files (with instructions) that can be transported to another machine
to create the recover SD card with.  The files will be in the folder:

`/opt/yocto-ornl-YYYY-MM-DD_HHMM/`

With the time based on when the `make archive` command is called.

## Manual Step-by-Step Method

This method describes the various steps needed in all the gory details.  These instructions
are taken from the upstream project that this unit is based off of.  The details have been
adjusted so that they apply to this project.

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
YOCTO_DIR=$HOME/ornl-dart-yocto
YOCTO_ENV=build_ornl
</pre>

<pre>
mkdir -p $YOCTO_DIR && cd $YOCTO_DIR
$YOCTO_DIR> repo init -u https://github.com/varigit/variscite-bsp-platform.git -b sumo
$YOCTO_DIR> repo sync -j4
</pre>

### Download ORNL layer

<pre>
$YOCTO_DIR> git clone https://github.com/uvdl/yocto-ornl.git -b merge/DevelopRefactor
$YOCTO_DIR> cp -r yocto-ornl/sources/meta-ornl sources
</pre>

### Set-up Yocto build environment

<pre>
$YOCTO_DIR> MACHINE=var-som-mx6-ornl DISTRO=fslc-framebuffer . setup-environment $YOCTO_ENV
</pre>

### Build Yocto

- Before building the project, overwrite the configuration files

<pre>
$YOCTO_DIR> cp yocto-ornl/build/conf/local.conf $YOCTO_ENV/conf/
$YOCTO_DIR> cp yocto-ornl/build/conf/bblayers.conf $YOCTO_ENV/conf/
</pre>

### Finally, start the build

<pre>
$YOCTO_DIR> cd $YOCTO_ENV
$YOCTO_DIR/$YOCTO_ENV> bitbake var-dev-update-full-image
</pre>

## Semi-Automatic Methods

These methods describe how to use some of the Makefile automation or scripting to prepare your
shell environment for executing `bitbake` commands that are needed when developing/debugging the
Yocto layers and the build process.  They are typically used by developers.

### Full Setup with default yocto-ornl branch

This option will install all the dependencies needed, clone and pull all needed repos, and make the build directory for you.  All you need to do is
run the following command : 

<pre>
./BuildScripts/ornl-setup-yocto.sh [path_to_new_build_directory] [version_of_yocto]
</pre>

*path_to_new_build_directory* - this is simply the path that you wish to have the new build directory located, i.e. /home/user/Workspace
*version_of_yocto* - the only versions of Yocto that are supported currently are sumo and thud.

Default branch is develop

### Full Setup with User defined yocto-ornl branch

This option will do the same as the previous but will the option to define what branch of the ORNL Yocto layer you want. All you need to do is
run the following command : 

<pre>
./BuildScripts/ornl-setup-yocto.sh -c [user_def_branch] [path_to_new_build_directory] [version_of_yocto]
</pre>

*user_def_branch* - This is the branch that you wish the script to checkout when a new version of uvdl/yocto-ornl is cloned
The last two arguments are the exact same as before.

### Run just the setup-environment script

This will **NOT** go through the entire setup prcoess.  This can be thought of as just a wrapper for the setup-environment script that you have to
run in order to run bitbake.  This will **ALSO** copy the local.conf and bblayers.conf files into the build directory.  

<pre>
./BuildScripts/ornl-setup-yocto.sh -b [path_to_build_directory]
</pre>

This assumes the build directory has already been created.  Just pass the path to the build directory and it *should* be happy.

### Use the Makefile target

The makefile has an environment making target, which some prefer to use.

This will create the build environment and give you additional instructions that
you will need to run to configure your shell:

<pre>
make YOCTO_DIR=[path_to_build_directory] environment
</pre>

This will synchronize an *existing* environment with any changes in *this* repo that have
been updated.  *(Since this configuration is itself a repository, the standard workflows
apply - this helps updated a working, evolved build environment so as to take advantage
of Yocto's dependency and partial compilation system to save time.)*

<pre>
make YOCTO_DIR=[path_to_build_directory] environment-update
</pre>

### Finally, start the build

Once the above setup scripts have run, you will need to move to your build location.  Once there, run the setup environment script again.
This step is common for all semi-automatic method uses.  The reason is that the Yocto build system stores
state information in the environment variables of the *CURRENT SHELL*.  This means that *EACH SHELL*
must have its call to `setup-environment` made before any of the `bitbake` commands will do anything
rational.  The Makefile `environment` calls will give you instructions, but they will be similar to:

<pre>
$YOCTO_DIR> MACHINE=var-som-mx6-ornl DISTRO=fslc-framebuffer . setup-environment $YOCTO_ENV
</pre>

Afterwards, you may issue `bitbake` commands:
 
<pre>
$YOCTO_DIR/$YOCTO_ENV> bitbake var-dev-update-full-image
</pre>

#### Using Toaster

You may wish to use 'Toaster', a dashboard for Yocto builds.  To prepare for using it, do:

<pre>
make YOCTO_DIR=[path_to_build_directory] toaster
</pre>

Then after setting up your environment do this once before issuing `bitbake` commands:

<pre>
$YOCTO_DIR/$YOCTO_ENV> source toaster stop ; source toaster start
</pre>

Then, open a browser to http://localhost:8000 to get the UI.

## Create an SDcard

Use the var-create-yocto-sdcard.sh script that is supplied by Variscite under the meta-variscite-fslc layer.  We have a companion script that can be run from this directory, use the following command. This will **ONLY** copy the Variscite script to the new directory.  From there just follow the directions from the [Variscite Build Guide](https://variwiki.com/index.php?title=Yocto_Build_Release&release=RELEASE_SUMO_V1.2_VAR-SOM-MX6#Create_an_extended_SD_card)

**NOTES**
- The Yocto Path needs to be the full path.

When using the Variscite script use the -a **AND** -r options. The following command should be used : 

<pre>
sudo MACHINE=var-som-mx6-ornl $YOCTO_DIR/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh -a -r $YOCTO_DIR/$YOCTO_ENV/tmp/deploy/images/$MACHINE/$YOCTO_IMG-$MACHINE /dev/xxx
</pre>
Where:
- /dev/xxx: The device that is the entire micro SD card. Example /dev/sdb
- $YOCTO_IMG: The name of the full image you used in the `bitbake` command.  I.e. `var-dev-update-full-image`
- $MACHINE: This is always `var-som-mx6-ornl` *(until its not, but thats another story...)*
- $YOCTO_DIR: This is the path to where the Yocto system was initialized
- $YOCTO_ENV: This is the name of the build folder in the path where Yocto was initialized. *Typically `build_ornl` unless you took pains to change it...*

## Flash SD To eMMC

Once the board has booted up run the install_yocto.sh script located in /usr/bin and follow the instructions below:

**NOTES**
- Please set the date on the device if it does not have the correct date+time

### To check and set the date

<pre>
date
date -s "yyyy-mm-dd hh:mm"
</pre>

### For one eMMC partition

In this scheme, the eMMC is used in its entirety and the root filesystem expands to the entire available space.

<pre>
/usr/bin/install_yocto.sh -b dart
</pre>

### For two eMMC partitions

In this scheme, the eMMC is split into two rootfs partitions and the bootloader boots into one of them.  During a swupdate, the unused partition is written to and the next reboot will boot that and make it the active.  This allows one known good configuration to always be available.

<pre>
/usr/bin/install_yocto.sh -b dart -u
</pre>

## OS Updates

To build images that can be used to update a running system, use the `*-swu` images.  These accompany the `*-update-full-image`.  For example, to build an update to the `var-dev-update-full-image`, build it first, then build `var-dev-image-swu`.  The artifacts produced will be in `$YOCTO_DEV/$YOCTO_ENV/tmp/deploy/images/$MACHINE` and will be named `var-dev-image-swu-$MACHINE-YYYYMMDDHHMMSS.swu` with a link to the latest one built called `var-dev-image-swu-var-som-mx6-ornl.swu`

### Updating a running system

Arrange for these `.swu` files to be loaded onto a running system and the swupdate process will start.  If networking is available on the target system, head to port `:8080` and follow the instructions to authenticate and load the `.swu` file.

