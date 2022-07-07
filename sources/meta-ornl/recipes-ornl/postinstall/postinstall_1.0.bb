SUMMARY = "Postinstall script to execute upon first login"
DESCRIPTION = "This is a script to be run upon first login to set the initial hostname and root password."
SECTION = "misc"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"
PR = "r11"

INHIBIT_DEFAULT_DEPS = "1"

SRC_URI = " file://postinstall.sh"

S = "${WORKDIR}"

FILES_${PN}-home = "${localstatedir}/local"

do_install() {
        install -d ${D}${localstatedir}/local
        install -m 0755 ${WORKDIR}/postinstall.sh ${D}${localstatedir}/local
}

COMPATIBLE_MACHINE = "(pix-c3)"
