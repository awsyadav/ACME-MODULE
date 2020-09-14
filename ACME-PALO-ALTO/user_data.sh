#!/bin/bash\n
exec >>(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1\n
#echo export new_routers=$aws_network_interface >> /etc/dhcp/dhclient-enter-hooks.d/aws-default-route\n
ifdown eth0
ifup eth0
while true
  do
   resp=$(curl -s -S -g --insecure \https://${aws_eip.ManagementElasticIP.public_ip}/api/?type=op&cmd=<show><chassis-ready></chassis-ready></show>&key=LUFRPT10VGJKTEV6a0R4L1JXd0ZmbmNvdUEwa25wMlU9d0N5d292d2FXNXBBeEFBUW5pV2xoZz09\)
   echo $resp >> /tmp/pan.log
   if [[ $resp == *\[CDATA[yes\* ]] ; then
     break
   fi
  sleep 10s
done
apt-get update
apt-get install -y apache2 wordpress