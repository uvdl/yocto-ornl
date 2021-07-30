DESCRIPTION = "Tegra demo base image"

require tegra-image-common.inc ../../recipes-core/images/ornl-dev-image.bb

CORE_IMAGE_BASE_INSTALL += "${@bb.utils.contains('DISTRO_FEATURES', 'vulkan', 'packagegroup-tegra-vulkantests', '', d)}"
CORE_IMAGE_BASE_INSTALL += "libvisionworks-devso-symlink cuda-libraries "