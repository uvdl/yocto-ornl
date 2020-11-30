FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"
COMPATIBLE_MACHINE = "var-som-mx6-ornl"

LOCALVERSION = "-mx6"

SRCBRANCH = "feature/develop"
SRCREV = "1e242ad670734608c59eb0ee3974d98c3603f1a1"

KERNEL_SRC ?= "git://github.com/uvdl/linux-imx.git;protocol=git"

SRC_URI_append = " \
	${KERNEL_SRC};branch=${SRCBRANCH} \
"
ORNL_CONFIG = "imx_v7_iris2_defconfig"

# Let's try an in-tree defconfig:
KERNEL_DEFCONFIG ?= "${S}/arch/arm/configs/${ORNL_CONFIG}"
KBUILD_DEFCONFIG ?= "${S}/arch/arm/configs/${ORNL_CONFIG}"
KCONFIG_MODE="--alldefconfig"

S = "${WORKDIR}/git"

# I'm not 100% sure this is necessary, I'm going to leave it because it could be useful
# in the future if we need to overwrite the defconfig and use the one in ${WORKDIR}
do_overwrite_defconfig() {
    bbnote "Copying defconfig"
    cp ${S}/arch/${ARCH}/configs/${ORNL_CONFIG} ${WORKDIR}/defconfig
}
addtask do_overwrite_defconfig before do_patch after merge_delta_config

