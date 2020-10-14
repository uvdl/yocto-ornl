DESCRIPTION = "Webcam Library" 
SECTION = "console/tools" 
LICENSE = "GPL-3" 
LIC_FILES_CHKSUM = "file://libwebcam/COPYING;md5=d32239bcb673463ab874e80d47fae504"
PR = "r0"

inherit pkgconfig cmake

DEPENDS = "libxml2"

SRCBRANCH ?= "master"
SRCREV = "bee2ef3c9e350fd859f08cd0e6745871e5f55cb9"
SRC_URI = "git://github.com/cshorler/webcam-tools.git;protocol=https;branch=${SRCBRANCH}"

SRC_URI[md5sum] = "53495d26a6135d5b3cd753aa490dd8ad"
SRC_URI[sha256sum] = "2f6c0f7bb39831e4ed3da5ed61020b018afb954d359c0d421f8b5f77431f4225"

S = "${WORKDIR}/git"
