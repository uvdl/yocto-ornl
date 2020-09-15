#!/bin/bash

# This is just a wrapper script for the SD card creation.  All this script will do is cp the 
# var-create-yocot-sdcard.sh script into the meta-variscite-fslc layer, overwriting the original 

help(){
    echo "./create-sd-card.sh 1 2 3 "
    echo "1 - FULL Path to the Yocto build directory"
    exit 1
}

if [ "$#" -ne 3 ] 
    then
        help
fi

readonly YOCTO_BUILD_DIRECTORY=$1

# copy the script over
cp -f var-create-yocto-sdcard.sh $YOCTO_BUILD_DIRECTORY/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh

