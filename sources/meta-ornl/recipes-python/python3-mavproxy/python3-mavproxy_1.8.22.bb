DESCRIPTION = "A MAVLink protocol proxy and ground station. MAVProxy is oriented towards command line operation, \ 
                and is suitable for embedding in small autonomous vehicles or for using on ground control stations"
SECTION = "devel/python"

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://COPYING.txt;md5=3c34afdc3adf82d2448f12715a255122"

SRC_URI[md5sum] = "98ceaa01313f5192ff463ff1795f25a9"
SRCREV = "20ebd823dc4758afab5d91c8effa682a4a099967"
SRCBRANCH ?= "master"
SRC_URI = "git://github.com/ArduPilot/MAVProxy.git;branch=${SRCBRANCH}"

S = "${WORKDIR}/git"

inherit setuptools3

RDEPENDS_${PN} += " python3-pymavlink"