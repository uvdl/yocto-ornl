DESCRIPTION = "Default static IP for eth0"

SRC_URI = "file://eth0.network \
"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd allarch

NATIVE_SYSTEMD_SUPPORT = "1"
SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_AUTO_ENABLE = "enable"

FILES_${PN} += "/etc/systemd/network/*.network"

do_install() {
	install -d ${D}/etc/systemd/network

	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		install -m 0644 ${WORKDIR}/eth0.network ${D}/etc/systemd/network
	fi
}
