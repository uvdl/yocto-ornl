FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
	file://swupdate.cfg \
"

SRC_URI_append_raspberrypi4-64 = " file://09-swupdate-args"
SRC_URI_append_var-som-mx6-ornl = " file://swupdate.default"

do_install_append () {
	install -d ${D}${sysconfdir}
    install -m 644 ${WORKDIR}/swupdate.cfg ${D}${sysconfdir}
}

do_install_append_raspberrypi4-64() {
	install -m 0644 ${WORKDIR}/09-swupdate-args ${D}${libdir}/swupdate/conf.d/
}

do_install_append_var-som-mx6-ornl() {
	install -d ${D}${sysconfdir}/default/
	install -m 644 ${WORKDIR}/swupdate.default ${D}${sysconfdir}/default/swupdate
}