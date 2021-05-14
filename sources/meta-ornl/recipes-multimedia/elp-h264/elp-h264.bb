SUMMARY = "ELP UVC H.264 Linux Binary"
LICENSE = "CLOSED"

FILESEXTRAPATH_prepend := "${THISDIR}/${PN}:"

SRCBRANCH ?= "master"
SRCREV = "274fb791469b453d7945aa854e94bdd0798cb723"
SRC_URI = "git://github.com/yokeap/ELP_H264_UVC.git;protocol=https;branch=${SRCBRANCH} \
    file://UvcChanges.patch \
"

S = "${WORKDIR}/git/Linux_UVC_TestAP"
INSANE_SKIP_${PN} = "ldflags"

FILES_${PN} += "/usr/bin/H264_UVC_TestAP"

do_compile() {
    make all
}

do_install() {
    mkdir -p ${D}/usr/bin/
    install -d ${D}/usr/bin/

    install -m 0755 ${S}/H264_UVC_TestAP ${D}/usr/bin/
}
