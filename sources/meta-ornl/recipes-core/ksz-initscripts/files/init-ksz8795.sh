#!/bin/sh -e
### BEGIN INIT INFO
# Provides:          init-ksz8795
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:
### END INIT INFO
DESC=init-ksz8795

SPI=/sys/bus/spi/devices
SWREG=$SPI/spi0.0/sw/reg
CONFIG=0xff

case $1 in
	start)
		# load module (looks like the first time it fails)
		modprobe -v spi-ksz8795
		rmmod spi-ksz8795
		if modprobe -v spi-ksz8795 ; then
			# set register to enable KSZ8794 switch
			echo 0x56=$CONFIG > $SWREG
		fi
		;;
	*)
		;;
esac
