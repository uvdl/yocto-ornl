SUMMARY = "Script to verify hardware interfaces on boards made"
DESCRIPTION = "This is a script that can be run to verify hardware is working."
SECTION = "misc"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"
PR = "r1"

INHIBIT_DEFAULT_DEPS = "1"

SRC_URI = " file://mfgtest.sh"

S = "${WORKDIR}"

FILES_${PN}-home = "${localstatedir}/local"

do_install() {
        install -d ${D}${localstatedir}/local
        install -m 0755 ${WORKDIR}/mfgtest.sh ${D}${localstatedir}/local
}

COMPATIBLE_MACHINE = "(var-som-mx6|var-som-mx6-ornl)"
