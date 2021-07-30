FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"
FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot-variscite/${MACHINE}:"

LOCALVERSION_var-som-mx6-ornl = "-imx6ul"

SRC_URI_append += " \
    file://uvdl_kernel_5-4.patch \
    file://imx_v7_iris2_defconfig \
    file://uvdl_kernel_otp.patch \
    file://uvdl_kernel_mxc.patch \
"

KBUILD_DEFCONFIG_var-som-mx6-ornl = "imx_v7_iris2_defconfig"

do_copy_config(){
    cp ${WORKDIR}/imx_v7_iris2_defconfig ${S}/arch/${ARCH}/configs/
}
addtask copy_config before do_kernel_metadata after do_unpack

COMPATIBLE_MACHINE = "var-som-mx6-ornl"
