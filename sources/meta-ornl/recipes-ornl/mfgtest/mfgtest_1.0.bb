SUMMARY = "Script to verify hardware interfaces on boards made"
DESCRIPTION = "This is a script that can be run to verify hardware is working."
SECTION = "misc"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"
PR = "r3"

INHIBIT_DEFAULT_DEPS = "1"

SRC_URI = " \
    file://mfgtest.sh \
    file://temperature.conf \
    file://temperature.service \
    file://temperature.sh \
"

S = "${WORKDIR}"

RDEPENDS_${PN} += "bash"

FILES_${PN}-home = "${localstatedir}/local"
FILES_${PN} += "${systemd_unitdir}/system/*.service"
FILES_${PN} += "${localstatedir}/local/*.sh"

do_install() {
        install -d ${D}${localstatedir}/local
        install -m 0755 ${WORKDIR}/mfgtest.sh ${D}${localstatedir}/local
        install -m 0755 ${WORKDIR}/temperature.sh ${D}${localstatedir}/local

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system
        install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
        install -m 0644 ${WORKDIR}/temperature.service ${D}${systemd_unitdir}/system
        ln -sf ${systemd_unitdir}/system/temperature.service \
            ${D}${sysconfdir}/systemd/system/multi-user.target.wants/temperature.service
    fi
}

COMPATIBLE_MACHINE = "(var-som-mx6|var-som-mx6-ornl)"
