FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

do_install_append () {
    cat >> ${D}${sysconfdi}/fstab <<EOF
# Data Partition
/dev/mmcblk2p3   /config    ext4    rw, dev, noexec, auto, user, async     0   2
EOF
}