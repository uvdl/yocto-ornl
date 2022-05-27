EXTRA_OECONF_remove_pix-c3 = "--disable-x264"
EXTRA_OECONF_pix-c3 += "--enable-x264"

DEPENDS_pix-c3 += " x264"

PACKAGECONFIG_pix-c3 += " \
    x264 \
"

