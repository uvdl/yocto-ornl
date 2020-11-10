FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

LOCALVERSION_var-som-mx6-ornl = "-mx6"

SRCBRANCH = "imx_v2017.03_4.9.11_1.0.0_ga_var01"
UBOOT_SRC = "git://github.com/varigit/uboot-imx.git;protocol=git"
SRC_URI_append_var-som-mx6-ornl = " \
									${UBOOT_SRC};branch=${SRCBRANCH} \
									file://0001-adding-iris2-support.patch \
									file://0002-adding-more-iris2-support.patch \
			   	  "
SRCREV = "a7869c2cde98e5f5b1886d8f54dff321a7aa0597"

SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"

S = "${WORKDIR}/git"

COMPATIBLE_MACHINE_var-som-mx6-ornl = "var-som-mx6-ornl"