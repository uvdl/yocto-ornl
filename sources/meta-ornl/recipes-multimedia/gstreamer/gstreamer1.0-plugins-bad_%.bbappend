EXTRA_OECONF_remove = "--disable-x265"
EXTRA_OECONF += "--enable-x265"

DEPENDS += " x265"

PACKAGECONFIG_var-som-mx6-ornl += " \ 
    rtmp \
    voaacenc \
"