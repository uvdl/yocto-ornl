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

#### `linuxsystembuilder.ornl.gov`

When using the Cades VM (or an AWS instance to build), you will need to copy the archive file back to your local machine in order to put it on an SD card.  Here is what I use for Cades *(substituting the actual date code to the archive folder)*:

<pre>
scp -r -i cadescloudvm.pem cades@linuxsystembuilder.ornl.gov:/opt/yocto-ornl-YYYY-MM-DD_HHMM .
</pre>

Afterward, you will see the following files, with `readme.txt` giving hints as to what you can do:

```
~/yocto-ornl-2021-06-22_1603$ ls -al
total 398424
drwxr-xr-x  4 6ov users      4096 Jun 22 16:06 .
drwxr-xr-x 41 6ov users      4096 Jun 22 16:06 ..
drwxr-xr-x  4 6ov users      4096 Jun 22 16:06 build_ornl
drwxr-xr-x  2 6ov users      4096 Jun 22 16:06 dts
-rw-r--r--  1 6ov users        44 Jun 22 16:06 hashes
-rw-r--r--  1 6ov users 187886014 Jun 22 16:06 kernel-source.tgz
-rw-r--r--  1 6ov users       301 Jun 22 16:06 readme.txt
-rw-r--r--  1 6ov users   7960688 Jun 22 16:06 uImage
-rw-r--r--  1 6ov users 212102144 Jun 22 16:06 var-dev-image-10.223.0.1-16.swu
~/yocto-ornl-2021-06-22_1603$ cat readme.txt 
# To write image to MMC, do:
DEV=/dev/sdx
sudo MACHINE=var-som-mx6-ornl build_ornl/sources/meta-variscite-fslc/scripts/var-create-yocto-sdcard.sh -a -r build_ornl/tmp/deploy/images/var-som-mx6-ornl/var-dev-update-full-image-var-som-mx6-ornl ${DEV}
# load var-dev-image-10.223.0.1-16.swu to port :9080
```

To figure out what to use for `/dev/sdx`, you can use the follwing command to determine what your microSD card was mapped at:

<pre>
dmesg | tail -3
</pre>

Which will give you something like:
```
6ov@uvdl3:~/opt/cades/yocto-ornl-2021-06-22_1603$ dmesg | tail -3
[18601.606923] sd 11:0:0:1: [sde] 31457280 512-byte logical blocks: (16.1 GB/15.0 GiB)
[18601.612617]  sde: sde1 sde2
[18602.243590] EXT4-fs (sde2): mounted filesystem with ordered data mode. Opts: (null)
```

So in this case, we would set `DEV=/dev/sde` to flash this microSD card with the above instruction.

## Flash SD To eMMC

### Boot up the board

Boot up the board with the micro SD card that was prepared above.  If your system has not been flashed before, you may experience a 90sec delay.
Then, the system will go into 'emergency mode':
```
You are in emergency mode. After logging in, type "journalctl -xb" to view
system logs, "systemctl reboot" to reboot, "systemctl default" or "exit"
to boot into default mode.
Give root password for maintenance
(or press Control-D to continue):
```

**Don't panic**.  Go ahead and give the root password for the image and you will get a shell prompt.

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

You should see the following:
```
*** Variscite MX6 Yocto eMMC/NAND Recovery ***

Carrier board: DART-MX6
Creating two rootfs partitions
<<< bunch of stuff about partitions >>>
Setting U-Boot enviroment variables

Yocto installed successfully
```
