DESCRIPTION = "Include file for how to install dotnet SDK package"
SECTION = "runtime"

S = "${WORKDIR}/dotnet-${PV}/"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=9fc642ff452b28d62ab19b7eea50dfb9"

DEPENDS = "zlib unzip"
RDEPENDS_${PN} = "bash icu lttng-tools lttng-ust zlib libgssglue krb5 libgssapi-krb5"


INSANE_SKIP_${PN} += "already-stripped libdir textrel"
INSANE_SKIP_${PN}-dbg += "libdir"
INSANE_SKIP_${PN} += "staticdev"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

FILES_${PN} += " \
	${datadir}/dotnet \
	/etc/profile.d/dotnet.sh \
"

do_install() {
	install -d ${D}${datadir}/dotnet/
	install -d ${D}/etc/profile.d/

    cp -rf ${S}* ${D}${datadir}/dotnet/
	cp -f ${WORKDIR}/dotnet.sh ${D}/etc/profile.d/
}

