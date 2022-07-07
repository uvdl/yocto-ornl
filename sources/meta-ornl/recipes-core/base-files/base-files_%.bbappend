FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

do_install_append_pix-c3 () {
    cat >> ${D}${sysconfdir}/fstab <<EOF
# Data Partition
/dev/mmcblk2p3   /config    ext4    rw,dev,noexec,auto,nofail,user,async     0   2
EOF
}
