EXTRA_OECONF_remove = "--disable-x265"
EXTRA_OECONF += "--enable-x265"

DEPENDS += " x265"

# Even though they contain the same, I thought it best
# to keep machine specifics separate in case of future add-ons

PACKAGECONFIG_pix-c3 += " \ 
    rtmp \
    voaacenc \
"

PACKAGECONFIG_raspberrypi4-64 += " \
    rtmp \
    voaacenc \
"
