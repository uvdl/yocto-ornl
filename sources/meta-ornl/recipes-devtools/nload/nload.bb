SUMMARY = "nLoad tools for development purposes"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=cbbd794e2a0a289b9dfcc9f513d1996e"

S = "${WORKDIR}/git"

DEPENDS = "ncurses"

PV = "v0.7.4"
SRCBRANCH ?= "master"
SRC_URI = "git://github.com/rolandriegel/nload.git;protocol=https;tag=${PV} \ 
    file://nload.1 \
"

# This is already stripped of debugging info
INSANE_SKIP_${PN} += "already-stripped"

do_copy_file() {
    cp -f ${WORKDIR}/nload.1 ${S}/docs
}
addtask copy_file before do_install after do_configure

inherit autotools pkgconfig gettext