SUMMARY = "n2n source build"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://COPYING;md5=d2dd9497ff2aa79327dc88b6ce2b03cc"

S = "${WORKDIR}/git"

PV = "3.0"
SRCBRANCH ?= "3.0-stable"
SRC_URI = "git://github.com/ntop/n2n.git;protocol=https;branch=${SRCBRANCH};tag=${PV} \ 
"

inherit cmake

FILES_${PN} = " \
    /usr/share \
    /usr/share/man7 \
    /usr/share/man8 \
    /usr/share/man1 \
    /usr/share/man7/n2n.7.gz \
    /usr/share/man8/edge.8.gz \
    /usr/share/man1/supernode.1.gz \
    /usr/sbin/edge \
    /usr/sbin/supernode \
    /usr/bin/n2n-benchmark \
"

DEPENDS += "openssl"