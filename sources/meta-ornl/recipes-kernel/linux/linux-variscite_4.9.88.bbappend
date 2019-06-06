FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

LOCALVERSION_var-som-mx6-ornl = "-mx6"

SRCBRANCH_var-som-mx6-ornl = " feature/uvc-composite-driver "
SRCREV_var-som-mx6-ornl = "e1b6a829e08fe664fd76ddaffd11eb8c29f1dc33"
KERNEL_SRC_var-som-mx6-ornl ?= "git://github.com/uvdl/linux-imx.git;protocol=git"

SRC_URI_append_var-som-mx6-ornl = " \
									${KERNEL_SRC};branch=${SRCBRANCH} \
									file://ornl_defconfig \
									"

KERNEL_DEFCONFIG_var-som-mx6-ornl = "${WORKDIR}/ornl_defconfig"

COMPATIBLE_MACHINE_var-som-mx6-ornl = "var-som-mx6-ornl"