# UVDL Yocto Install Guide

## Fully Automatic Method

This option takes advantage of Makefile automation.

Important environment variables are:
  * `USER = jsmith` - can be used to control where archive and ephemeral are built
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
export USER=<choice>
export S3=<choice>
</pre>

If you do not wish to import there are variable examples in the Makefile that you can uncomment. **NOTE**: if you choose to use these default variables remember to do the same in the **submodules** (specifically *yocto-ornl*)

Once these variables are set, you can build:

<pre>
make environment
make build
make archive
</pre>

This will produce a set of files (with instructions) that can be transported to another machine
to create the recover SD card with.  The files will be in the folder:

`/opt/var-YYYY-MM-DD_HHMM/` or `/opt/rasp-YYYY-MM-DD_HHMM/` or `/opt/tegra-YYYY-MM-DD_HHMM/`

With the time based on when the `make archive` command is called. If an s3 bucket location is specified `make archive` will also upload to that bucket

#### `linuxsystembuilder.ornl.gov`

On the Cades VM, I typically do the following *(after make dependencies is done once)*:

<pre>
for k in clean toaster all ; do make $k ; done
</pre>

Also, if using CADES be sure and use the pre-build folders:

<pre>
/data/share/${MACHINE}/downloads/
/data/share/${MACHINE}/sstate/
</pre>

Go into the local.conf file in `yocto-ornl` and uncomment them. They are defaulted to use CADES folder organization.

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

## Manual Step-by-Step Method for the Variscite SoM

The manual method is deprecated (because it was not kept up to date).  Use the automatic methods.
The steps can be found at `Documentation/VarisciteManualBuild.md`

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

## Create an SDcard for the Variscite SoM

Instructions for creating a microSD card is available for the Variscite IMX6 SOM.  See `Documentation/VarisciteSdCard.md` for details.

## Clean a specific recipe

At times, a build will fail during development and you will need to clean out what was previously built.  It can be painful to go to the build directory start a bitbake server then type out what you want to clean.  To make things easier the Makefile has the ability to clean the recipe for you.  Just run the command below:

<pre>
make clean-recipe RECIPE=<choice>
</pre>

Whatever *RECIPE* is given, bitbake will attempt a *bitbake -c cleanall RECIPE*.  This will save you the hassle of having to go start a new bitbake server and do it manually.