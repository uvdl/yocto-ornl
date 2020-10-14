FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"
FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot-variscite/${MACHINE}:"

SRC_URI_append_var-som-mx6-ornl = " \
    file://fw_env.config \
	file://0001-adding-iris2-support.patch \
	file://0002-adding-more-iris2-support.patch \
    "

do_compile_var-som-mx6-ornl () {
	oe_runmake mx6var_som_sd_defconfig
	oe_runmake env
	mv tools/env/fw_printenv tools/env/fw_printenv-mmc
	oe_runmake mx6var_som_nand_defconfig
	oe_runmake env
}