SUMMARY = "Gstreamer Daemon 1.0"
DESCRIPTION = "GStreamer framework for controlling audio and video streaming using TCP connection messages"
HOMEPAGE = "https://developer.ridgerun.com/wiki/index.php?title=Gstd-1.0"
SECTION = "multimedia"
LICENSE = "GPLv2+"

LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS = "gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-bad gstreamer1.0-rtsp-server json-glib libdaemon jansson"

# TODO :: test this. Last several builds have only ended up in 0.6.2
PV = "0.10.0"
SRCBRANCH ?= "master"
SRCREV = "09863c510b3d947ae360f445f7b170fe25c09bf9"
SRC_URI = "git://github.com/RidgeRun/gstd-1.x.git;protocol=https;tag=0.10.0 \
	   file://0001-gstd-yocto-compatibility.patch"

S = "${WORKDIR}/git"

FILES_${PN} += "/run/gstd"

inherit autotools pkgconfig gettext

do_configure() {
        ${S}/autogen.sh
        oe_runconf
}

do_install() {
        autotools_do_install
        install -d ${D}/run/gstd
        rm -rf ${D}/var/run
}
