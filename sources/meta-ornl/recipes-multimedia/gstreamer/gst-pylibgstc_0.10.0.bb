SUMMARY = "Gst python abstraction"
DESCRIPTION = "GStreamer framework for controlling audio and video streaming using TCP connection messages"
HOMEPAGE = "https://developer.ridgerun.com/wiki/index.php?title=Gstd-1.0"
SECTION = "multimedia"
LICENSE = "GPLv2+"

LIC_FILES_CHKSUM = "file://../COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

PV = "v0.10.0"
SRCBRANCH ?= "master"
SRC_URI = "git://github.com/RidgeRun/gstd-1.x.git;protocol=https;tag=${PV}"

S = "${WORKDIR}/git/libgstc"

FILES_${PN} += "/run/gstd"

inherit setuptools3
