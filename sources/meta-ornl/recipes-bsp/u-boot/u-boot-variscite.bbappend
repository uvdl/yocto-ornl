FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"
FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot-fw-utils:"

LOCALVERSION_var-som-mx6-ornl = "-mx6"

SRC_URI_append_var-som-mx6-ornl += " file://uvdl_u-boot_4_14.patch \ 
	file://fw_env.config \
"

COMPATIBLE_MACHINE_var-som-mx6-ornl = "var-som-mx6-ornl"