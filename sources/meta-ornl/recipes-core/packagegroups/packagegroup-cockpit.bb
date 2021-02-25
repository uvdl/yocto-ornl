DESCRIPTION = "Cockpit Packages"
SUMMARY = "Provide the needed packages to run Cockpit on a device"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \    
    cockpit \
	cockpit-ws \
	cockpit-users \
	cockpit-shell \
	cockpit-networkmanager \
	cockpit-systemd \
"
