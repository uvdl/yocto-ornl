DESCRIPTION = "Webcam Library" 
SECTION = "console/tools" 
LICENSE = "BSD-2-Clause" 
# LIC_FILES_CHKSUM = "file://libwebcam/COPYING;md5=d32239bcb673463ab874e80d47fae504"

inherit pkgconfig autotools

TAGVERSION="accepted/tizen/ivi/20160218.024246"
SRC_URI = "git://github.com/TizenTeam/dos2unix.git;protocol=https;tag=${TAGVERSION}"

# SRC_URI[md5sum] = "53495d26a6135d5b3cd753aa490dd8ad"
# SRC_URI[sha256sum] = "2f6c0f7bb39831e4ed3da5ed61020b018afb954d359c0d421f8b5f77431f4225"

S = "${WORKDIR}/git"