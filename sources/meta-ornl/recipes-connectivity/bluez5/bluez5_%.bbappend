FILESEXTRAPATHS_prepend := "${THISDIR}/files:"


SRC_URI_append_pix-c3 = " \
	file://variscite-bt.conf \
"

do_install_append_pix-c3() {
	install -m 0644 ${WORKDIR}/variscite-bt.conf ${D}${sysconfdir}/bluetooth
}

