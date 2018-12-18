FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

LOCALVERSION_var-som-mx6-ornl = "-mx6"


KERNEL_DEFCONFIG_var-som-mx6-ornl = "${S}/arch/arm/configs/imx_v7_var_defconfig"

COMPATIBLE_MACHINE_var-som-mx6-ornl = "var-som-mx6-ornl"
