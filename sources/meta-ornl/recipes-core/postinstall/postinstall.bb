SUMMARY = "Postinstall script to execute upon first login"
DESCRIPTION = "This is a script to be run upon fisrt login \
to set the initial hostname and root password."
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI_append = " file://postinstall.sh"

PR = "r2"

S = "${WORKDIR}"

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES_${PN} = "${localstatedir}/* ${libdir}/*"

do_install() {
        install -d ${D}${localstatedir}/home/root
        install -m 0644 ${WORKDIR}/postinstall.sh ${D}${localstatedir}/home/root
}

COMPATIBLE_MACHINE = "(var-som-mx6|var-som-mx6-ornl)"
