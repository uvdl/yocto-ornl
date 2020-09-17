DESCRIPTION = "Webcam Library" 
SECTION = "console/tools" 
LICENSE = "GPL-3" 
LIC_FILES_CHKSUM = "file://webcam-tools/libwebcam/COPYING;md5=d32239bcb673463ab874e80d47fae504"
PR = "r0"

inherit pkgconfig cmake

DEPENDS = "libxml2"

SRCREV = "bee2ef3c9e350fd859f08cd0e6745871e5f55cb9"
SRC_URI = "https://github.com/cshorler/webcam-tools.git;protocol=https"

SRC_URI[md5sum] = "a5e166f35522df10431718db0c849118"
SRC_URI[sha256sum] = "2f6c0f7bb39831e4ed3da5ed61020b018afb954d359c0d421f8b5f77431f4225"

S = "${WORKDIR}/src"