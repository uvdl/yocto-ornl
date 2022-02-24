EXTRA_OECONF_remove = "--disable-x265"
EXTRA_OECONF += "--enable-x265"

DEPENDS += " x265"

# Even though they contain the same, I thought it best
# to keep machine specifics separate in case of future add-ons

PACKAGECONFIG_var-som-mx6-ornl += " \ 
    rtmp \
    voaacenc \
"

PACKAGECONFIG_raspberrypi4-64 += " \
    rtmp \
    voaacenc \
"
