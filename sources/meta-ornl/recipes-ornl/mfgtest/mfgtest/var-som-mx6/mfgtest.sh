#!/bin/bash

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
tests[eth0]="ping -c 4 192.168.0.2"
tests[python3]="python3 --version"
tests[h264]="gst-launch-1.0 -f videotestsrc num-buffers=30 is-live=true ! imxvpuenc_h264 ! fakesink"
tests[h265]="gst-launch-1.0 -f videotestsrc num-buffers=30 is-live=true ! x265enc ! fakesink"

# run programs and inspect results of tests to ensure existence of devices
declare -A inspections
inspections[usb]="lsusb"

declare -A comparisons
comparisons[usb]="grep 1d6b:0002 $TMPDIR/usb"

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
echo "*** $sn ***"
any=false
for r in ${!results[@]} ; do
	echo -n "$r: "
	if ${results[$r]} ; then echo "OK" ; else echo "FAILED ***" ; any=true ; fi
done
if $any ; then exit 1 ; fi
exit 0

