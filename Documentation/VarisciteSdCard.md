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
