FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

SRC_URI_append += " \
    file://usb-serial.cfg \
"

COMPATIBLE_MACHINE = "(ts7180|ts7553v2)"