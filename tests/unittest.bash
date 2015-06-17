#!/bin/bash
# 2015-06-01 (cc) <paul4hough@gmail.com>
#
# FIXME - need a lock step for renaming vm
#
[ -n "$DEBUG" ] && set -x
targs="$0 $@"
# cfg
testname=r7j_ansible_bacula_sd
baseimg="/var/lib/libvirt/images/r7test-base.qcow2"
imgfn="`pwd`/r7test.qcow2"
ssh_opts="-i r7t_jenkins.id -o StrictHostKeyChecking=no"

function Dbg {
  [ -n "$DEBUG" ] && echo $@
}

function Die {
  echo Error - $? - $@
  virsh shutdown $testname
  chmod 644 r7t_jenkins.id
  exit 1
}
#DoOrDie
function DoD {
  $@ || Die $@
}

echo $imgfn
DoD cp "$baseimg" "$imgfn"
DoD chmod +w "$imgfn"
DoD chmod 600 r7t_jenkins.id

sed -e "s~%imgfn%~$imgfn~g" -e "s~%name%~$testname~g" r7test.xml.tmpl > r7test.xml
DoD virsh create r7test.xml

while true; do
  sleep 10
  vgip=`awk -e '/r7jenkins/ {print $3}' /var/lib/libvirt/dnsmasq/default.leases`
  if [ -n "$vgip" ] ; then break; fi
  let tcnt=tcnt+1
  if [ $tcnt -gt 5 ] ; then exit 1; fi
done
Dbg $vgip
echo $testname > hostname
DoD scp $ssh_opts hostname root@$vgip:/etc/hostname
ssh $ssh_opts root@$vgip shutdown -r now
sleep 10
# make sure our new host name has come up.
DoD grep $testname /var/lib/libvirt/dnsmasq/default.leases > /dev/null

# config node with ansible
cat <<EOF  > unittest.inv
[unittest]
$vgip          ansible_ssh_private_key_file=`pwd`/r7t_jenkins.id
EOF

aparg=
if [ -n "$DEBUG" ] ; then aparg='-v' ; fi
DoD ansible-playbook $aparg -i unittest.inv unittest.yml

# guest specific tests
DoD ssh $ssh_opts root@$vgip bash unittest.guest.bash

# cleanup
DoD virsh shutdown $testname
chmod 644 r7t_jenkins.id
echo $targs complete.
exit 0
