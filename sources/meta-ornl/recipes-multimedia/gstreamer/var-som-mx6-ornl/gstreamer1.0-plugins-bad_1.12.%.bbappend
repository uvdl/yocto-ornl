COMPATIBLE_MACHINE = "var-som-mx6-ornl"
EXTRA_OECONF_remove = "--disable-x265"
EXTRA_OECONF += "--enable-x265"

DEPENDS += " x265"

PACKAGECONFIG += " \ 
    rtmp \
    voaacenc \
"