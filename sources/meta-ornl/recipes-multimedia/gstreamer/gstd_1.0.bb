SUMMARY = "Gstreamer Daemon 1.0"
DESCRIPTION = "GStreamer framework for controlling audio and video streaming using TCP connection messages"
HOMEPAGE = "https://developer.ridgerun.com/wiki/index.php?title=Gstd-1.0"
SECTION = "multimedia"
LICENSE = "GPLv2+"

LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS = "libsoup-2.4 gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-bad gstreamer1.0-rtsp-server json-glib libdaemon jansson"

PV = "v0.11.3"
SRCBRANCH ?= "master"
SRC_URI = "git://github.com/RidgeRun/gstd-1.x.git;protocol=https;tag=${PV} \
	   file://0001-gstd-v113-yocto-compatibility.patch"

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
