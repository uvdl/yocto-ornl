## Using the tar.gz image

After a Tegra board is build, a tar.gz file is created th contains everything that is needed to flash you tegra SoM.  If you are using the Cades VM, you can either push the image to an s3 bucket with the `make archive` command or you can just pull that image off the VM with a program like WinSCP.  Once you have it in the desired location expand the file : 

<pre>
tar -xf tegra_file.tar.gz
</pre>

In this directory, you now have everything you need to flash the board.

### Setting up the board

In order to flash the SoM you need to do some pre-flash setup.  Follow [these](https://github.com/OE4T/meta-tegra/wiki/Flashing-the-Jetson-Dev-Kit) instructions to get your board into recovery mode.

### Flash Script

Once the board is in recovery mode and you have expanded your tar file, run the doflash.sh script.  If your user name is not part of the plugdev group then you may need to run the script as root (sudo).  This will begin the flash procedure and will reboot once its finished.

**NOTE** 
If the script fails to run, or gets stuck running.  Two quick things to check, first if you are flashing a regular devkit (not an emmc) make sure there is an SD card in the slot.  Second, make sure the ${MACHINE} you built is indeed the one you are attempting to flash.  This happens on occation and is a huge pain, but the boards are so similar its easy to make the mistake.