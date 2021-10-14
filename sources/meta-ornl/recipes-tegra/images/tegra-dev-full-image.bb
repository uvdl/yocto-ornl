DESCRIPTION = "Full Tegra image with X11, OpenCV, \
and Tegra multimedia API sample apps."

require tegra-image-common.inc recipes-core/images/ornl-dev-image.bb

IMAGE_FEATURES += "splash x11-base hwcodecs"

NETWORK_MANAGER ?= "networkmanager"

inherit features_check

IMAGE_INSTALL_append += " \
    nvgstapps \
    deepstream-5.1 \
    libvisionworks \
    exiftool \
    cudnn \
    cuda-samples \
    tensorrt-core \
    gstreamer1.0-plugins-nvvideo4linux2 \
"

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
