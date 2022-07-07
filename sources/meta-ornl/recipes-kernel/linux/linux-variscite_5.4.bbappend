FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"
FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot-variscite/${MACHINE}:"

LOCALVERSION_pix-c3 = "-imx6ul"

SRC_URI_append_pix-c3 += " \
    file://uvdl_kernel_5-4.patch \
    file://imx_v7_iris2_defconfig \
    file://uvdl_kernel_otp.patch \
    file://uvdl_kernel_mxc.patch \
"

KBUILD_DEFCONFIG_pix-c3 = "imx_v7_iris2_defconfig"

do_copy_config(){
    cp ${WORKDIR}/imx_v7_iris2_defconfig ${S}/arch/${ARCH}/configs/
}
addtask copy_config before do_kernel_metadata after do_unpack

COMPATIBLE_MACHINE = "pix-c3"
