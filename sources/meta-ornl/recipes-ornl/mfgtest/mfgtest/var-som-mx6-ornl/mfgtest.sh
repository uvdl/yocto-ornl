#!/bin/bash

BRD=${1}
if [ -z "$BRD" ] ; then
	read -p "Board Identity? " BRD
fi
HOST=${2-10.223.0.2}
if [ -z "$HOST" ] ; then
	read -p "Ping Host? " HOST
fi
TMPDIR=/tmp/$$
mkdir -p $TMPDIR

# determine serial number by reading FUSES
sn1=`cat /sys/fsl_otp/HW_OCOTP_CFG0`
sn2=`cat /sys/fsl_otp/HW_OCOTP_CFG1`
if [ ! -z "$sn1" ] && [ ! -z "$sn2" ] ; then
	sn=$(printf 'IMX6%0.8x%0.8x\n' $sn1 $sn2)
else
	sn=$(printf 'XMAC%0.8x%0.8x\n' 0 0)
fi

# declare tests to exectute on platform as command lines
declare -A tests
tests[eth0]="ping -c 4 $HOST"
tests[python3]="python3 --version"
tests[h264]="gst-launch-1.0 -f videotestsrc num-buffers=30 is-live=true ! imxvpuenc_h264 ! fakesink"
tests[h265]="gst-launch-1.0 -f videotestsrc num-buffers=30 is-live=true ! x265enc ! fakesink"

# run programs and inspect results of tests to ensure existence of devices
declare -A inspections
inspections[usb]="lsusb"

declare -A comparisons
comparisons[usb]="grep 1d6b:0002 $TMPDIR/usb"
comparisons[hub]="grep 0424:2514 $TMPDIR/usb"
comparisons[gps]="grep 1546:01a8 $TMPDIR/usb"
comparisons[cellular-modem]="grep 1546:1143 $TMPDIR/usb"

declare -A results

##########################################
# (mostly) BOILERPLATE from here on out...
##########################################

# perform tests defined above
for t in ${!tests[@]} ; do
	results[$t]=false && echo "*** ${tests[$t]}"
	if ${tests[$t]} ; then results[$t]=true ; fi
done

# run programs that produce output to be inspected by the comparisons[]
set -e
for t in ${!inspections[@]} ; do
	${inspections[$t]} | tee -a $TMPDIR/$t
done
set +e

# perform comparisons defined above
for t in ${!comparisons[@]} ; do
	results[$t]=false && echo "*** ${comparisons[$t]}"
	${comparisons[$t]} | tee -a $TMPDIR/check-${t}
	if [ -s $TMPDIR/check-${t} ] ; then results[$t]=true ; fi
done

# report on status of tests
echo ""
echo "*** $BRD ***"
echo "CPU: $sn"
any=false
for r in ${!results[@]} ; do
	echo -n "$r: "
	if ${results[$r]} ; then echo "OK" ; else echo "FAILED ***" ; any=true ; fi
done

# construct a .csv file and emit it
echo -n "CPU," > $TMPDIR/${BRD}.csv
if [ -s /tmp/temperature.csv ] ; then echo -n "uptime,temperature," >> $TMPDIR/${BRD}.csv ; fi
for r in ${!results[@]} ; do echo -n "${r}," >> $TMPDIR/${BRD}.csv ; done ; echo "" >> $TMPDIR/${BRD}.csv
echo -n "${sn}," >> $TMPDIR/${BRD}.csv
if [ -s /tmp/temperature.csv ] ; then
	x=$(tail -1 /tmp/temperature.csv)
	t=$(echo $x | cut -f3 -d, | awk '{printf("%.3f",$1/1000)}')
	echo -n "$(echo $x | cut -f2 -d,),$t," >> $TMPDIR/${BRD}.csv
fi
for r in ${!results[@]} ; do
	if ${results[$r]} ; then
		echo -n "OK," >> $TMPDIR/${BRD}.csv
	else
		echo -n "FAIL," >> $TMPDIR/${BRD}.csv
	fi
done
echo "" >> $TMPDIR/${BRD}.csv
echo ""
echo "*** $TMPDIR/${BRD}.csv ***"
cat $TMPDIR/${BRD}.csv

if $any ; then exit 1 ; fi
exit 0

