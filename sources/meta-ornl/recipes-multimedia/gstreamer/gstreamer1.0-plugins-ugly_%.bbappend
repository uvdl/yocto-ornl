EXTRA_OECONF_remove_var-som-mx6-ornl = "--disable-x264"
EXTRA_OECONF_var-som-mx6-ornl += "--enable-x264"

DEPENDS_var-som-mx6-ornl += " x264"

PACKAGECONFIG_var-som-mx6-ornl += " \
    x264 \
"

