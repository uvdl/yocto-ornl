DESCRIPTION = "KSZ init scripts"

SRC_URI_var-som-mx6-ornl = "file://init-ksz8795.sh \
    file://init-ksz9897.sh \
    file://init-ksz8795.service \
    file://init-ksz9897.service \
"

LICENSE = "CLOSED"

inherit systemd allarch

NATIVE_SYSTEMD_SUPPORT = "1"
SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} = "init-ksz8795.service init-ksz9897.service"
SYSTEMD_AUTO_ENABLE = "enable"

FILES_${PN} += "${systemd_unitdir}/system/*.service"
FILES_${PN} += "${base_sbindir}/*.sh"

do_install_var-som-mx6-ornl() {
  install -d ${D}${base_sbindir}
  install -m 0755 ${WORKDIR}/init-ksz8795.sh ${D}${base_sbindir}
  install -m 0755 ${WORKDIR}/init-ksz9897.sh ${D}${base_sbindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
      install -d ${D}${systemd_unitdir}/system
      install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
      install -m 0644 ${WORKDIR}/init-ksz8795.service ${D}${systemd_unitdir}/system
      install -m 0644 ${WORKDIR}/init-ksz9897.service ${D}${systemd_unitdir}/system

      ln -sf ${systemd_unitdir}/system/init-ksz8795.service \
          ${D}${sysconfdir}/systemd/system/multi-user.target.wants/init-ksz8795.service
      ln -sf ${systemd_unitdir}/system/init-ksz9897.service \
          ${D}${sysconfdir}/systemd/system/multi-user.target.wants/init-ksz9897.service
    fi
}