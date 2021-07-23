DESCRIPTION = "Packagegroup for inclusion in all Tegra images"

LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    nvgstapps \
    deepstream-5.1 \
    exiftool \
    haveged \
    procps \
    sshfs-fuse \
    strace \
    tegra-tools-tegrastats \
"