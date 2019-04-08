FILESEXTRAPATHS_prepend_var-som-mx6-ornl := "${THISDIR}/${PN}/${MACHINE}:"

SRC_URI_append_var-som-mx6-ornl = " \
									file://interfaces \
                                "
