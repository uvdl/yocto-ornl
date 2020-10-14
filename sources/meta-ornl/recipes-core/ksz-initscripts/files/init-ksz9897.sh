#!/bin/sh -e
### BEGIN INIT INFO
# Provides:          init-ksz9897
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:
### END INIT INFO
DESC=init-ksz9897

SPI=/sys/bus/spi/devices
SWREG=$SPI/spi0.0/sw/reg
CONFIG=0x5b

case $1 in
	start)
		# load module and configure
		if modprobe -v spi-ksz9897 ; then
			# set register to enable KSZ9893 switch
			echo 0x3301=$CONFIG > $SWREG
		fi
		;;
	*)
		;;
esac
