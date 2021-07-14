# UVDL Yocto Install Guide

## Fully Automatic Method

This option takes advantage of Makefile automation.

Important environment variables are:

  * `ARCHIVE := /opt` - controls the folder where the output files are written
  * `EPHEMERAL := $(HOME)` - controls the folder where the yocto builds are made
  * `HOST := 10.223.0.1` - controls the default eth0 address of the processor
  * `NETMASK := 16` - controls the netmask to be used
  * `YOCTO_PROD := dev` - controls which yocto image to build {dev, prod, min}

Ensure the environment variables are set:

<pre>
export ARCHIVE=<path>
export EPHEMERAL=<path>
export MACHINE=<choice>
export YOCTO_PROD=<choice>
</pre>

Once these variables are set, you can build:

<pre>
make dependencies
make environment
make build
make archive
</pre>

This will produce a set of files (with instructions) that can be transported to another machine
to create the recover SD card with.  The files will be in the folder:

`/opt/yocto-ornl-YYYY-MM-DD_HHMM/`

With the time based on when the `make archive` command is called.

#### `linuxsystembuilder.ornl.gov`

On the Cades VM, I typically do the following *(after make dependencies is done once)*:

<pre>
for k in clean toaster all ; do make $k ; done
</pre>

### Quick Fully Automatic Method

This option takes advantage of even more Makefile automation.  If you have already
done the fully automatic method above **(at least the `make dependencies` part)**,
then you can use the following steps to build images with the desired IP address
for the `eth0` port that will be needed for future software updates.

<pre>
make HOST=w.x.y.z NETMASK=n swu
</pre>

The above will build an SD card image as well as a .swu update file and archive
them into a folder that can be taken to another machine or used to program a
micro SD card as in the [flash sd to emmc](#flash-sd-to-emmc) section below.

The files will be stored in `/opt/yocto-ornl-yyyy-mm-dd_hhmm` **(or wherever the `ARCHIVE` variable points to)**.
The environment variables can be overriden in the make command, for example:

<pre>
make ARCHIVE=/tmp HOST=192.168.1.10 NETMASK=24 swu
</pre>

Would build a micro SD/.swu full os image for a system
whose eth0 port will be defined as 192.168.1.10/24.

#### `linuxsystembuilder.ornl.gov`

On the Cades VM, I typically do the following *(for a vehicle in the `Testing` comm group (octet 13) vehicle sysid 10 (a.k.a. R1-24)*:

<pre>
make HOST=172.20.13.10 NETMASK=16 swu
</pre>

### `EPHEMERAL`

The EPHEMERAL variable controls where the yocto build directory will be placed.  This is an
important folder because:

  a) it cannot be moved because all the yocto files reference it by full pathname
  b) it holds alot of cached files that if present will speed up future builds
  c) it is strictly tied to the yocto base system **(sumo, thud, dunfell, etc.)**
  d) it rises to about 76GB after a build completes

So, where this goes on your system makes a big difference.  The Makefile uses `/tmp` as the
default, but you may want this to exist on something else (such as `/dev/shm` if your system
has alot of memory, or a mount point to a fast storage drive).  If you wish to be able to
restart your system and keep the build state you have, then ensure EPHEMERAL points to a
persistent storage volume.

#### `linuxsystembuilder.ornl.gov`

This Cades VM is setup as a build resource.  It has an NVMe disk mounted at `/ephemeral`, so your EPHEMERAL environment variable will need to be set as: `export EPHEMERAL=/ephemeral`

<pre>
make HOST=192.168.0.1 NETMASK=24 swu
</pre>

## Manual Step-by-Step Method

The manual method is deprecated (because it was not kept up to date).  Use the automatic methods.
The steps can be found at `Documentation/VarisciteManualBuild.md`

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

#### Creating and Using an SDK

You may wish to create an SDK cross-compiler that has the same toolchain and installed libraries as the full image above.  To get this:

<pre>
$YOCTO_DIR/$YOCTO_ENV> bitbake -c populate_sdk var-dev-update-full-image
</pre>

Upon success a shell archive will be available in `$YOCTO_DIR/$YOCTO_ENV/tmp/deploy/sdk/fslc-framebuffer-glibc-x86_64-var-dev-update-full-image-armv7at2hf-neon-toolchain-2.6.2.sh`.  Copy this file to a new machine and execute it to unpack the SDK.  *(it will ask you where to extract it, refer to that folder as SDK_DIR)*

**In the fully automatic method, you can say:**
<pre>
make EPHEMERAL=[path_to_ephemeral_directory] sdk
</pre>

Once this is done, please do the following:

<pre>
> source $SDK_DIR/environment-setup-armv7at2hf-neon-fslc-linux-gnueabi
> $CC --version
arm-fslc-linux-gnueabi-gcc (GCC) 8.2.0
Copyright (C) 2018 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
</pre>

It is important to use the `$CC` variable when compiling as it has been setup with the correct compiler, the needed libraries, etc.

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

#### `linuxsystembuilder.ornl.gov`

When using the Cades VM (or an AWS instance to build), you will need to create an SSH tunnel to forward TCP/IP port 8000 to your local machine:

<pre>
ssh -i cadescloudvm.pem -L 8000:localhost:8000 cades@linuxsystembuilder.ornl.gov
</pre>

The `.pem` file is the private key to enable login.  You will have your own if you made a VM or an AWS instance.  You can always start up another SSH if you forgot to do this when you initially logged in.  Then you can open your browser as described above.

## Create an SDcard

Instructions for creating a microSD card is available for the Variscite IMX6 SOM.  See `Documentation/VarisciteSdCard.md` for details.

## OS Updates

To build images that can be used to update a running system, use the `*-swu` images.  These accompany the `*-update-full-image`.  For example, to build an update to the `var-dev-update-full-image`, build it first, then build `var-dev-image-swu`.  The artifacts produced will be in `$YOCTO_DEV/$YOCTO_ENV/tmp/deploy/images/$MACHINE` and will be named `var-dev-image-swu-$MACHINE-YYYYMMDDHHMMSS.swu` with a link to the latest one built called `var-dev-image-swu-var-som-mx6-ornl.swu`

### Updating a running system

Arrange for these `.swu` files to be loaded onto a running system and the swupdate process will start.  If networking is available on the target system, head to port `:8080` and follow the instructions to authenticate and load the `.swu` file.

