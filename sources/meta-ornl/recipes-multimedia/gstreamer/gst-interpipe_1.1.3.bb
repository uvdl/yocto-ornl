SUMMARY = "Gstreamer Interpipe 1.1.3"
DESCRIPTION = "GStreamer plug-in that allows communication between two independent pipelines"
HOMEPAGE = "https://developer.ridgerun.com/wiki/index.php?title=GstInterpipe"
SECTION = "multimedia"
LICENSE = "LGPL2.1"

LIC_FILES_CHKSUM = "file://COPYING;md5=3191ae9476980e87e3494d2d8ebe4584"

DEPENDS = "gstreamer1.0 gstreamer1.0-plugins-base"

PV = "v1.1.3"
SRCBRANCH ?= "master"
SRC_URI = "git://github.com/RidgeRun/gst-interpipe.git;protocol=https;tag=${PV}"

S = "${WORKDIR}/git"

FILES_${PN} += "${libdir}/gstreamer-1.0/libgstinterpipe.so "

inherit autotools pkgconfig gettext

do_configure() {
${S}/autogen.sh --noconfigure

oe_runconf
}
