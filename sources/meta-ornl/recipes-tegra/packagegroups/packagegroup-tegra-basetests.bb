DESCRIPTION = "Packagegroup for common Tegra test applications"

LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    cuda-samples \
"