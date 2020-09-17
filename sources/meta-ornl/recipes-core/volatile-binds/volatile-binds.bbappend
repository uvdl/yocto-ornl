# We need to extend the places that are writable in a 
# read-only fs
VOLATILE_BINDS += " \
    /tmp/ {$ROOT_HOME}/ \
"