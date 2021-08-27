DESCRIPTION = "This is ONLY included to append to the environment file in etc"

# Only needed for running locally.
do_install_append() {
    install -d ${D}/etc/
    cat >> ${D}/etc/environment <<EOF
# Indicator of how to write to the /etc/environment file 
EOF
}


