#!/bin/bash
LOG=/tmp/temperature.csv
PERIOD=10
THERMAL=/sys/class/thermal/
n=0
echo "Logging to $LOG, $PERIOD sec period"
echo -n "date/time,uptime," >> $LOG
for d in $THERMAL/thermal_zone* ; do
	echo -n "zone$n," | tee -a $LOG
	n=$(($n + 1))
done
echo "" | tee -a $LOG

while true ; do
	echo -n "$(date --iso-8601=seconds)," >> $LOG
	echo -n "$(awk '{printf("%02d:%02d:%02d",int($1/3600),int($1%3600/60),int($1%60))}' /proc/uptime)," >> $LOG
	for d in $THERMAL/thermal_zone* ; do
		x=$(cat $d/temp)
		echo -n "$x," | tee -a $LOG
	done
	echo "" | tee -a $LOG
	sleep $PERIOD
done
