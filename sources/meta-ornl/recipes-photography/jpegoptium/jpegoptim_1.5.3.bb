SUMMARY = "utility to optimize/compress JPEG files"
LICENSE = "GPLv3"

S = "${WORKDIR}/git"

PV = "v1.5.0"
SRC_URI = "git://github.com/tjko/jpegoptim.git;protocol=https;tag=${PV} "

inherit autotools pkgconfig gettext