DESCRIPTION = "Packagegroup for common Tegra Vulkan test apps"

LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    vulkan-tools \
"