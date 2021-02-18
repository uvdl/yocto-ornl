FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"
FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot-fw-utils:"

LOCALVERSION_var-som-mx6-ornl = "-mx6"

# SRCBRANCH = "iris2"
# UBOOT_SRC = "git://github.com/uvdl/uboot-imx.git;protocol=git"
SRC_URI_append_var-som-mx6-ornl += " file://uvdl_u-boot_4_14.patch \ 
	file://fw_env.config \
"
# SRCREV = "7a70a5b5fe517a89391c309d801a0a2e9fd06c5f"

# S = "${WORKDIR}/git"

COMPATIBLE_MACHINE_var-som-mx6-ornl = "var-som-mx6-ornl"