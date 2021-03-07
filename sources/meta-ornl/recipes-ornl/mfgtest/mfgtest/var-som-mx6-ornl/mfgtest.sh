#!/bin/bash

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

declare -A results

##########################################
# (mostly) BOILERPLATE from here on out...
##########################################

function identifier() {
	echo "$1" | cut -f1 -d,
}
function content() {
	echo "$1" | cut -f2 -d,
}

# perform tests defined above
for t in ${!tests[@]} ; do
	results[$t]=false && echo "*** ${tests[$t]}"
	if ${tests[$t]} ; then results[$t]=true ; fi
done

# report on status of tests
echo ""
echo "*** $sn ***"
any=false
for r in ${!results[@]} ; do
	echo -n "$r: "
	if ${results[$r]} ; then echo "OK" ; else echo "*** FAILED" ; any=true ; fi
done
if $any ; then exit 1 ; fi
exit 0

