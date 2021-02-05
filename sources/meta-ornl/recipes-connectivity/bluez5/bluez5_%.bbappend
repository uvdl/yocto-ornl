FILESEXTRAPATHS_prepend := "${THISDIR}/files:"


SRC_URI_append_var-som-mx6-ornl = " \
	file://variscite-bt.conf \
"

do_install_append_var-som-mx6-ornl() {
	install -m 0644 ${WORKDIR}/variscite-bt.conf ${D}${sysconfdir}/bluetooth
}

