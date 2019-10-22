#!/bin/bash
sn1=`cat /sys/fsl_otp/HW_OCOTP_CFG0`
sn2=`cat /sys/fsl_otp/HW_OCOTP_CFG1`
printf 'IMX6%0.8x%0.8x\n' $sn1 $sn2 > /etc/hostname
cat /etc/hostname
passwd
