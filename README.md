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

With the addition of this build running on multiple platforms the following changes **MUST** be made to the Makefile
in order to build the correct image.

### Required Makefile Variables

1. The **MACHINE** variable needs to be set with one of the following : 

<pre>
var-som-mx6-ornl
jerson-xavier-nx-devkit (or any jetson board that needs to be built)
</pre>

2. The **YOCTO_DISTRO** variable needs to be set with one of the following : 

<pre>
fslc-framebuffer (only for var-som-mx6-ornl)
ornl-tegra (only for jetson boards)
</pre>

3. The **YOCTO_IMAGE** variable needs to be set, common builds are: 

<pre>
var-dev-update-full-image (var-som-mx6-ornl only)
tegra-dev-full-image (jetson boards only)
</pre>

### Optional Makefile Variables

1. You can change where you want the build directory created if you chage the variable **YOCTO_DIR**.
The default location is in `/tmp/yocto-ornl-version/` (where `version` is the common name for the yocto version eg *sumo*) but can be anywere.

2. You can change where you want your archive directory if you change the variable **ARCHIVE**.
The default location is in `/opt/` but can be anywhere.

## Creating and Using an SDK

You may wish to create an SDK cross-compiler that has the same toolchain and installed libraries as the full image above.  To get this:

<pre>
$YOCTO_DIR/$YOCTO_ENV> bitbake -c populate-sdk var-dev-update-full-image
</pre>

Upon success a shell archive will be available in `$YOCTO_DIR/$YOCTO_ENV/tmp/deploy/sdk/fslc-framebuffer-glibc-x86_64-var-dev-update-full-image-armv7at2hf-neon-toolchain-2.6.2.sh`.  Copy this file to a new machine and execute it to unpack the SDK.  *(it will ask you where to extract it, refer to that folder as SDK_DIR)*

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

## Using Toaster

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

The steps for created an SD card for the Variscite board for this system can be found in the [VarisciteSdCard.md](Documentation/VarisciteSdCard.md) file.

The steps for flashing an NVIDIA dev board can be found [here](https://github.com/OE4T/meta-tegra/wiki/Flashing-the-Jetson-Dev-Kit).  For now,
the only tested board with this build is the *jetson-xavier-nx-devkit*