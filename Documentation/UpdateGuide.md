# UVDL Yocto Update Guide

### General Notes

This guide takes roots from the [Variscite SWUpdate Guide](https://variwiki.com/index.php?title=SWUpdate_Guide&release=RELEASE_SUMO_V1.2_VAR-SOM-MX6).  SWUpdate is a popular, open source
update schema that the Yocto community has embraced.  The previous link gives a brief overview of what Variscite has done to support OTA updates.

In general we do a two partition update.  This is the most robust way to go about an update **and** these projects, _so far_, have the extra storage space to make this happen.

## Variscite DART Update

### Update Images
Previously only two images exist to build, ornl-dev-image and ornl-tstar-image.  These were meant to be generic (board agnostic) images that contain only what is necessary for a particular project.  With the addition of SWUpdate, two more images in the recipes-core folder were created.  These images are specifically for the Variscite DART builds. They add bootable _image\_installs_ to the image (located in /boot) since with the dual rootfs update schema the boot partition is no longer needed.  Due to these board specific additions, new images were needed.  These images will **require** that the base images will be built, and will extend those base images to add **only** necessary changes.  The ornl-dev-image is a good example, the base image gives everything needed to develop on a system, the extended image is named var-dev-update-full-image.  If one runs the following command:

<pre>
bitbake var-dev-update-full-image
</pre>

That command will build the base image (ornl-dev-image) if not already built, then it will contine with building and adding the changes needed for the update.

### Update Artifacts
SWUpdate is normally found in source under the meta-layer/recipes-support directory.  In the ornl-recipes/swupdate directory you will find a few new .bb files.

swupdate_%d.bbappend - this file appends a new swupdate directory structure for bitbake to view **and** it installs new swupdate.cfg files for the particular device. Example is adding the var-som-mx6-ornl device.
var-dev-image-swu.bb - this is the recipe for building an update artifact.
var-tstar-image-swu.bb - same as the previous .bb file, it creates an update artifact for the tstar project.

An SWUpdate build artifact is what the SWUpdate daemon uses to update rootfs with. For a full description of SWUpdate go [here](https://sbabic.github.io/swupdate/swupdate.html), as too much general SWUpdate information is probably out of this documents scope.  These rescipies use the var-xxx-update-full-image images to build a package to be able to update the device.  Several different update types are allowed, but Variscite paved the way for sending out a full .tar file and an update script for giving the procedure to do the full update.  For this solution the only command needed to build an artifact is : 

<pre>
# build a dev artifact
bitbake var-dev-image-swu
</pre>

When commpleted, in the $build_dir$/tmp/deploy/images/var-som-mx6-ornl/ directory there will now be an archive named var-dev-image-swu-var-som-mx6-ornl.swu.  That is what the SWUpdate daemon will use in order to update rootfs.

### Server
SWUpdate is packaged with [Mongoose](https://github.com/cesanta/mongoose) which is an embedded web server.  This definitely does not have to be the final solution, this is just a quick and dirty way to get the artifact onto the board easily.

### eMMC Preparation Note
This is more of an append to the the proper way to build the full image.  If you look at the README file, when using Option 2 to get the OS up and running, you can use the install_yocto.sh script.  All that script does is copy the image from the SD card to eMMC.  In order to get the update schema working the -u option needs to be used when invoking the script:

<pre>
./install_yocto -b dart -u
</pre>

This tells the script that two rootfs partitions needs to be used.

### Dev Example
Given a build directory build_dir that has been setup with either the setup_environment script **or** via the ornl-setup-yocto.sh with -b and **NO** previous builds being done, run the following command:

<pre>
bitbake var-dev-update-full-image
</pre>

Next, follow the instructions from the README file and use Option 2 with the addition of the -u option in the eMMC install script.  Once that is accomplished, make a change to the layer.  You could add a new recipe that has a script that you can see, or if you have a recipe for a working project make changes to your code base, then run the following command :

<pre>
bitbake var-dev-image-swu
</pre>

Once that has completed, just connect to the embedded web server using the static IP address:9080 and drag and drop the .swu file into the box.  From there the SWUpdate daemon will handle the rest!

