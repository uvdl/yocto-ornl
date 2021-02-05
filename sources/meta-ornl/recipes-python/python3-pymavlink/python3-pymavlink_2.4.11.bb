DESCRIPTION = "A Python library for handling MAVLink protocol streams and log files."
SECTION = "devel/python"

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://COPYING;md5=6ea13ec5f0f3dd35ac5b53afdc3ed9ff"

SRC_URI[md5sum] = "e8b24b6523444b7b4a6acbc9d7b97504"
SRC_URI[sha256sum] = "0b1265b169f809c6ca94911ad2d7649b8e087a7cc573a0a6ea62ade9bea7ca5c"

inherit pypi setuptools3

DEPENDS += "python3-future-native"

RDEPENDS_${PN} += " python3-future python"

do_get_lic() {
    mkdir -p ${WORKDIR}/git
    git clone https://github.com/ArduPilot/pymavlink.git ${WORKDIR}/git
    cp ${WORKDIR}/git/COPYING ${WORKDIR}/pymavlink-2.4.11/
}
addtask do_get_lic before do_populate_lic