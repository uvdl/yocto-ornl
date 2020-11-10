FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"
FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot-variscite/${MACHINE}:"

SRCBRANCH = "imx_v2017.03_4.9.11_1.0.0_ga_var01"
UBOOT_SRC = "git://github.com/varigit/uboot-imx.git;protocol=git"
SRC_URI_append_var-som-mx6-ornl = " \
	${UBOOT_SRC};branch=${SRCBRANCH} \
	file://fw_env.config \
	file://0001-adding-iris2-support.patch \
	file://0002-adding-more-iris2-support.patch \
	"
SRCREV = "a7869c2cde98e5f5b1886d8f54dff321a7aa0597"

do_compile_var-som-mx6-ornl () {
	oe_runmake mx6var_som_sd_defconfig
	oe_runmake env
	mv tools/env/fw_printenv tools/env/fw_printenv-mmc
	oe_runmake mx6var_som_nand_defconfig
	oe_runmake env
}