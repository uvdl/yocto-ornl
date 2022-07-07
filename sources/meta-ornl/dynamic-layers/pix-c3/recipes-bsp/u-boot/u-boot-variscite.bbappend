FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"
FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot-fw-utils:"

LOCALVERSION_pix-c3 = "-mx6"

SRC_URI_append_pix-c3 += " file://uvdl_u-boot_4_14.patch \ 
	file://fw_env.config \
"

COMPATIBLE_MACHINE = "pix-c3"