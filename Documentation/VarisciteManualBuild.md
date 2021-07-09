## Manual Step-by-Step Method

**(*WARNING:* these steps are out of date)**

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
