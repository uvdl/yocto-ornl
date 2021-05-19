#!/bin/bash
set -e

EULA=1	# https://patchwork.openembedded.org/patch/100815/
LANG=en_US.UTF-8
TOASTER_PORT=8000

# Known variations
# FIXME: requires mod to BuildScripts/ornl-setup-yocto.sh
MACHINE=var-som-mx6-ornl
YOCTO_CMD=
YOCTO_DIR=/tmp
YOCTO_ENV=build_ornl

help() {
	bn=`basename $0`
	echo " Usage: $bn <options> bitbake-command"
	echo
	echo " options:"
	echo " -d		override YOCTO_DIR (default ${YOCTO_DIR})"
	echo " -e		override YOCTO_ENV (default ${YOCTO_ENV})"
	echo " -h		display this Help message"
	echo " -m		define MACHINE (default ${MACHINE}); valid:"
    echo "          var-som-mx6-ornl, var-som-mx6 - Variscite DART-MX6"
    echo "          jetson-xavier-nx-devkit - Jetson Xavier NX on devkit"
    echo "          raspberrypi4-64 - RPi Compute Module 4"
	echo " -tp		override TOASTER_PORT (default ${TOASTER_PORT})"
	echo
	echo " Example: $bn ornl-bitbake.sh -m var-som-mx6-ornl -d /ephemeral/yoctl-ornl-dunfell -e dunfell var-dev-update-full-image"
	echo
	echo " options:"
	echo
}

# Parse command line
moreoptions=1
while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
	    -d) shift ; YOCTO_DIR=${1} ;;
	    -e) shift ; YOCTO_ENV=${1} ;;
	    -h) help; exit 3 ;;
	    -m) shift ; MACHINE=${1} ;;
	    -tp) shift ; TOASTER_PORT=${1} ;;
	    *)  moreoptions=0; YOCTO_CMD=$* ; break ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 1 ] && help && exit 1
	[ "$moreoptions" = 1 ] && shift
done

# NB: *EVERY* call to bitbake must have its environment prepared by setup-environment
case ${MACHINE} in
var-som-mx6-ornl)
    cp -rf build/conf/variscite/* ${YOCTO_DIR}/${YOCTO_ENV}/conf/
    cd ${YOCTO_DIR}
        MACHINE=${MACHINE} DISTRO=${YOCTO_DISTRO} EULA=${EULA} . setup-environment ${YOCTO_ENV}
    ;;
jetson-xavier-nx-devkit)
	cp -rf build/conf/jetson/* ${YOCTO_DIR}/${YOCTO_ENV}/conf/
	cd ${YOCTO_DIR}
		source ${YOCTO_DIR}/ornl-yocto-tegra/setup-env --machine ${MACHINE} --distro ornl-tegra ${YOCTO_ENV}
    ;;
raspberrypi4-64)
	cp -rf build/conf/raspberrypi/* ${YOCTO_DIR}/${YOCTO_ENV}/conf/
	cd ${YOCTO_DIR}
		source ${YOCTO_DIR}/ornl-yocto-rpi/layers/poky/oe-init-build-env ${YOCTO_ENV}
    ;;
*)
	help
	exit 1
    ;;
esac

# FIXME: *OR* we may have to do it still if we switch between variscite/jetson/raspberrypi builds...
if [ "${YOCTO_CMD}" == "toaster install" ] ; then
	cd $(YOCTO_DIR)/sources/poky
		pip3 install --user -r bitbake/toaster-requirements.txt
		touch $(YOCTO_DIR)/$(YOCTO_ENV)/.toaster
elif [ "${YOCTO_CMD}" == "toaster start" ] ; then
    if [ -e ${YOCTO_DIR}/${YOCTO_ENV}/.toaster ] ; then
	    cd ${YOCTO_DIR}
	    source toaster stop && sleep 5
	    source toaster webport=0.0.0.0:${TOASTER_PORT} start
    fi
elif [ "${YOCTO_CMD}" == "toaster stop" ] ; then
    cd ${YOCTO_DIR}
    source toaster stop
elif [ ! -z "${YOCTO_CMD}" ] ; then
    # The reason this script exists at all...
	cd ${YOCTO_DIR}/${YOCTO_ENV}
    LANG=${LANG} bitbake ${YOCTO_CMD}
fi

exit 0

