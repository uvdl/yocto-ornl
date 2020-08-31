#!/bin/bash

# This is just a wrapper script for the SD card creation.  All this script will do is cp the 
# var-create-yocot-sdcard.sh script into the meta-variscite-fslc layer, overwriting the original 
# and running said script with the correct parameters for this particular device

# SPECIAL NOTE ::: This script currently DOES NOT do any file / directory checking.  Future plans are to implement if this 
# script still remains viable after the build script is created. For now be sure and DOUBLE CHECK what you are passing into this script.

help(){
    echo "./create-sd-card.sh 1 2 3 "
    echo "1 - FULL Path to the Yocto build directory"
    echo "2 - Device file associated with the sd card, i.e. /dev/sdx"
    echo "3 - Yocto image to write, i.e. ornl-dev-image-var-som-mx6-ornl"
    echo
    echo "Currently this script does NOT check directory / file integrity.  Please verify all information before proceeding. Future plans in the works :-)"
    exit 1
}

if [ "$#" -ne 3 ] 
    then
        help
fi

readonly YOCTO_BUILD_DIRECTORY=$1
readonly DEVICE_FILE=$2
readonly YOCTO_IMAGE=$3

# copy the script over
cp -f var-create-yocto-sdcard.sh $YOCTO_BUILD_DIRECTORY/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh

readonly CURRENT_DIR=$pwd

eval cd $YOCTO_BUILD_DIRECTORY

# run the script
sudo MACHINE=var-som-mx6-ornl sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh -a -r build_ornl/tmp/deploy/images/var-som-mx6-ornl/$YOCTO_IMAGE  $DEVICE_FILE 

