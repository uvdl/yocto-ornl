#!/bin/bash
set -e

ARCHIVE=/opt
PROJECT=yocto-ornl
DATE=$(date +%Y-%m-%d_%H%M)
_OUT=${ARCHIVE}/${PROJECT}-${DATE}

HOST=10.223.0.1
NETMASK=16

# Known variations
# FIXME: requires mod to BuildScripts/ornl-setup-yocto.sh
MACHINE=var-som-mx6-ornl
YOCTO_ENV=build_ornl
YOCTO_PROD=dev
YOCTO_DIR=/tmp

echo "============================="
echo "=  Archive creation script  ="
echo "============================="

help() {
	bn=`basename $0`
	echo " Usage: $bn <options> yocto-build-dir"
	echo
	echo " options:"
	echo " -h		display this Help message"
	echo " -e		override YOCTO_ENV (default ${YOCTO_ENV})"
	echo " -ip		override HOST (default ${HOST})"
	echo " -m		define MACHINE (default ${MACHINE}); valid:"
    echo "          var-som-mx6-ornl, var-som-mx6 - Variscite DART-MX6"
    echo "          jetson-xavier-nx-devkit - Jetson Xavier NX on devkit"
    echo "          raspberrypi4-64 - RPi Compute Module 4"
	echo " -nm		override NETMASK (default ${NETMASK})"
	echo " -o		override OUTPUT folder (default ${_OUT})"
	echo " -p		override YOCTO_PROD (default ${YOCTO_PROD}); valid"
    echo "          dev, prod, min"
	echo " -v		override YOCTO_VERSION (default ${YOCTO_VERSION}); valid"
    echo "          thud, dunfell, gatesgarth, etc."
	echo
	echo " Example: $bn ornl-create-archive.sh -p dev -m var-som-mx6-ornl -ip 172.18.0.1 -nm 16 /ephemeral/yoctl-ornl-dunfell"
	echo
	echo " options:"
	echo
}

# Parse command line
moreoptions=1
while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
	    -e) shift ; YOCTO_ENV=${1} ;;
	    -h) help; exit 3 ;;
	    -ip) shift ; HOST=${1} ;;
	    -m) shift ; MACHINE=${1}
            if [[ ($MACHINE == var-som-mx6 || $MACHINE == var-som-mx6-ornl) ]] ; then
                #MACHINE_FOLDER=variscite
                YOCTO_VERSION=dunfell
                #YOCTO_DISTRO=fslc-framebuffer
            elif [[ $MACHINE == raspberrypi4-64 ]] ; then
                #MACHINE_FOLDER=raspberrypi
                YOCTO_VERSION=gatesgarth
                #YOCTO_DISTRO=ornl-rpi
            elif [[ $MACHINE == jetson-xavier-nx-devkit ]] ; then
                #MACHINE_FOLDER=jetson
                YOCTO_VERSION=FIXME
                #YOCTO_DISTRO=FIXME
	    fi
        ;;
	    -nm) shift ; NETMASK=${1} ;;
	    -o) shift ; _OUT=${1} ;;
	    -p) shift ; YOCTO_PROD=${1} ;;
	    -v) shift ; YOCTO_VERSION=${1} ;;
	    *)  moreoptions=0; YOCTO_DIR=$1 ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 1 ] && help && exit 1
	[ "$moreoptions" = 1 ] && shift
done

### Boilerplate
KERNEL_DTS=tmp/deploy/images/${MACHINE}
KERNEL_IMAGE=tmp/deploy/images/${MACHINE}/uImage
KERNEL_SOURCE=${YOCTO_DIR}/${YOCTO_ENV}/tmp/work-shared/${MACHINE}/kernel-source

mkdir -p $_OUT

if [[ ($MACHINE == var-som-mx6 || $MACHINE == var-som-mx6-ornl) ]] ; then
    # .dtb and make .dts files out of them
	mkdir -p ${_OUT}/dts
	for f in `find ${YOCTO_DIR}/${YOCTO_ENV}/${KERNEL_DTS} -name "*.dtb" -print` ; do
        n=$(basename $f)
        nb=${n%.*}
        dtc -I dtb -O dts -o ${_OUT}/dts/${nb}.dts $f
        ( set -x && cp $f ${_OUT}/dts/${nb}.dtb )
    done

    # all generated artifacts
	mkdir -p ${_OUT}/${YOCTO_ENV}/tmp/deploy/images
	rsync --links -rtp --exclude={*.wic.gz,*.manifest,*testdata*,*.ubi*,*.cfg} ${YOCTO_DIR}/${YOCTO_ENV}/${KERNEL_DTS} ${_OUT}/${YOCTO_ENV}/tmp/deploy/images/

    # needed script(s) to make sd cards
	mkdir -p ${_OUT}/${YOCTO_ENV}/sources/meta-variscite-fslc/scripts
	cp -r BuildScripts/var-create-yocto-sdcard.sh ${_OUT}/${YOCTO_ENV}/sources/meta-variscite-fslc/scripts
	cp -r ${YOCTO_DIR}/sources/meta-variscite-fslc/scripts/var_mk_yocto_sdcard/variscite_scripts ${_OUT}/${YOCTO_ENV}/sources/meta-variscite-fslc/scripts

    # kernel image and sources
	cp ${YOCTO_DIR}/${YOCTO_ENV}/${KERNEL_IMAGE} ${_OUT}
	tar czf ${_OUT}/kernel-source.tgz -C $(dirname ${KERNEL_SOURCE}) $(basename ${KERNEL_SOURCE})

    # .swu files for this MACHINE
	( set -x ; swu=$(find ${YOCTO_DIR}/${YOCTO_ENV} -name "var-image-swu-${MACHINE}.swu" | head -1) ; set +x ;
		if [ ! -z ${swu} ] ; then set -x ; cp ${swu} ${_OUT}/var-${YOCTO_PROD}-image-${HOST}-${NETMASK}.swu ; fi )

    # the SDK for this MACHINE
	if [ -d ${YOCTO_DIR}/${YOCTO_ENV}/tmp/deploy/sdk ] ; then
        ( set -x ; cp -r ${YOCTO_DIR}/${YOCTO_ENV}/tmp/deploy/sdk ${_OUT} )
    fi

    # calculate hashes for various files
	commit=$(git log | head -1 | tr -s ' ' | cut -f2 | tr -s ' ' | cut -f2 -d' ') ;
        echo "yocto-ornl: $$commit" > ${_OUT}/hashes
	( cd ${KERNEL_SOURCE} && commit=$(git log | head -1 | tr -s ' ' | cut -f2 | tr -s ' ' | cut -f2 -d' ') ;
        echo "kernel: $$commit" >> ${_OUT}/hashes )

    # write instructions on use out
	echo "# To write image to MMC, do:" > ${_OUT}/readme.txt
	echo "DEV=/dev/sdx" >> ${_OUT}/readme.txt
	echo "sudo MACHINE=${MACHINE} ${YOCTO_ENV}/sources/meta-variscite-fslc/scripts/var-create-yocto-sdcard.sh -a -r ${YOCTO_ENV}/tmp/deploy/images/${MACHINE}/var-${YOCTO_PROD}-update-full-image-${MACHINE} \$\{DEV\}" >> ${_OUT}/readme.txt
	if [ -e ${_OUT}/var-${YOCTO_PROD}-image-${HOST}-${NETMASK}.swu ] ; then
        echo "# load var-${YOCTO_PROD}-image-${HOST}-${NETMASK}.swu to port :9080" >> ${_OUT}/readme.txt
    fi
	if [ -d ${_OUT}/sdk ] ; then
        echo "# A Cross-platform SDK is available in ./sdk" >> ${_OUT}/readme.txt
    fi

elif [[ $MACHINE == jetson-xavier-nx-devkit ]] ; then
	@tar -xf ${YOCTO_DIR}/${YOCTO_ENV}/tmp/deploy/images/${MACHINE}/jetson-${YOCTO_PROD}-full-image-${MACHINE}.tegraflash.tar.gz -C ${_OUT}

elif [[ $MACHINE == raspberrypi4-64 ]] ; then
	cp -f ${YOCTO_DIR}/${YOCTO_ENV}/tmp-glibc/deploy/images/${MACHINE}/raspberrypi-${YOCTO_PROD}-full-image-${MACHINE}.wic.bz2 ${_OUT}
	( cd ${_OUT} && bzip2 -d raspberrypi-${YOCTO_PROD}-full-image-${MACHINE}.wic.bz2 )

else
	help
	exit 1
fi

exit 0

