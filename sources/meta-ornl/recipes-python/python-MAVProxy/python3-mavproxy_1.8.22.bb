DESCRIPTION = "A MAVLink protocol proxy and ground station. MAVProxy is oriented towards command line operation, \ 
                and is suitable for embedding in small autonomous vehicles or for using on ground control stations"
SECTION = "devel/python"

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://COPYING.txt;md5=3c34afdc3adf82d2448f12715a255122"

# SRC_URI[md5sum] = "980dae7a748dd2c9d896c26f3ed6da35"
# SRC_URI[sha256sum] = "87d7f9c0b8f4f1db3ce3521f67cd244fe3b89ffead797e92f35a7f71bbe8b958"
SRC_URI[md5sum] = "98ceaa01313f5192ff463ff1795f25a9"
SRCREV = "20ebd823dc4758afab5d91c8effa682a4a099967"
SRCBRANCH ?= "master"
SRC_URI = "git://github.com/ArduPilot/MAVProxy.git;branch=${SRCBRANCH}"

S = "${WORKDIR}/git"

inherit setuptools3

RDEPENDS_${PN} += " python3-pymavlink"

# do_get_lic() {
#     mkdir -p ${WORKDIR}/git
#     git clone https://github.com/ArduPilot/MAVProxy.git ${WORKDIR}/git
#     cp ${WORKDIR}/git/COPYING.txt ${WORKDIR}/MAVProxy-1.8.22/
# }
# addtask do_get_lic before do_populate_lic