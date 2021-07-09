DESCRIPTION = "This is ONLY included to append to the environment file in etc"

# Only needed for running locally.
do_install_append() {
    install -d ${D}/etc/
    cat >> ${D}/etc/environment <<EOF
# for dotnet-core
DOTNET_ROOT=/usr/share/dotnet
PATH=$PATH:/usr/share/dotnet
EOF
}


