SUMMARY = "GstInference"
DESCRIPTION = "A GStreamer deep learning inference framework"
HOMEPAGE = "https://developer.ridgerun.com/wiki/index.php?title=GstInference"
SECTION = "multimedia"
LICENSE = "LGPL2.1"

LIC_FILES_CHKSUM = "file://COPYING;md5=d8c27221f54faf25f3df61a3463b245c"

DEPENDS = "gstreamer1.0 gstreamer1.0-plugins-base r2inference opencv"

SRCBRANCH ?= "master"
SRCREV = "4a11323ce74b80d05feba7a3d53a6c770de1248a"
SRC_URI = "git://github.com/RidgeRun/gst-inference;protocol=https;branch=${SRCBRANCH}"

S = "${WORKDIR}/git"

FILES_${PN} += "${libdir}/gstreamer-1.0/libgstinferenceoverlay.so "
FILES_${PN} += "${libdir}/gstreamer-1.0/libgstinference.so "

inherit autotools pkgconfig gettext

do_configure() {
${S}/autogen.sh --disable-gtk-doc --host x86_64
oe_runconf
}

