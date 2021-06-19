PACKAGES_remove = "${PN}-module-raid ${PN}-module-exports ${PN}-module-fdisk ${PN}-module-lvm"
PACKAGES += " ${PN}-theme-authentic-theme "
RDEPENDS_${PN}_remove = "mdadm perl-module-file-basename perl-module-file-path perl-module-cwd perl-module-file-spec perl-module-file-spec-unix parted lvm2"


