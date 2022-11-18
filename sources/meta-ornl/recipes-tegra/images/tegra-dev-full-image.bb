DESCRIPTION = "Full Tegra image with X11, OpenCV, \
and Tegra multimedia API sample apps."

require tegra-image-common.inc recipes-core/images/ornl-dev-image.bb

IMAGE_FEATURES += "splash x11-base hwcodecs"

NETWORK_MANAGER ?= "networkmanager"

inherit features_check

IMAGE_INSTALL_append += " \
    nvgstapps \
    exiftool \
    cudnn \
    cuda-samples \
    gstreamer1.0-plugins-tegra \
"

IMAGE_INSTALL_append_jetson-xavier-nx-devkit += " \
    deepstream-6.0 \
    libvisionworks \
    tensorrt-core \
"

IMAGE_INSTALL_append_jetson-xavier-nx-emmc-devkit += " \
    deepstream-6.0 \
    libvisionworks \
    tensorrt-core \
"

# These are needed for docker images

# These are needed for docker images
IMAGE_INSTALL_append += " \
    nvidia-docker \
    nvidia-container-runtime \
    cudnn-container-csv \
    libvisionworks-container-csv \
"

REQUIRED_DISTRO_FEATURES = "x11 opengl"

CORE_IMAGE_BASE_INSTALL += "${@bb.utils.contains('DISTRO_FEATURES', 'vulkan', 'packagegroup-tegra-vulkantests', '', d)}"
CORE_IMAGE_BASE_INSTALL += "libvisionworks-devso-symlink cuda-libraries "
