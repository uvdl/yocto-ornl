DESCRIPTION = "Cockpit packagegroup"
SUMMARY = "Cockpit packagegroup - needs to run cockpit on a device"

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