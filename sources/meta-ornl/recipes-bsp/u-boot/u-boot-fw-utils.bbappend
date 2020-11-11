FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"
FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot-variscite/${MACHINE}:"

SRCBRANCH = "iris2"
UBOOT_SRC = "git://github.com/uvdl/uboot-imx.git;protocol=git"
SRC_URI_append_var-som-mx6-ornl = " \
	${UBOOT_SRC};branch=${SRCBRANCH} \
	file://fw_env.config \
	"
SRCREV = "7a70a5b5fe517a89391c309d801a0a2e9fd06c5f"

do_compile_var-som-mx6-ornl () {
	oe_runmake mx6var_som_sd_defconfig
	oe_runmake env
	mv tools/env/fw_printenv tools/env/fw_printenv-mmc
	oe_runmake mx6var_som_nand_defconfig
	oe_runmake env
}