# remove additional packages pulled in by systemd
# https://stackoverflow.com/questions/52144173/systemd-customization

PACKAGECONFIG_remove = "timedated timesyncd"
