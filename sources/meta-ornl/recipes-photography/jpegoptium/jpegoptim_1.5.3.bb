SUMMARY = "utility to optimize/compress JPEG files"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1ebbd3e34237af26da5dc08a4e440464"

S = "${WORKDIR}/git"

PV = "v1.5.0"
SRC_URI = "git://github.com/tjko/jpegoptim.git;protocol=https;tag=${PV} "

inherit autotools pkgconfig gettext