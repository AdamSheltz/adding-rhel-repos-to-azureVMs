#!/bin/bash
checknetwork(){
echo "Checking path to Azure Rhel repos for public cloud."

#if ip/port is closed echo "check path to $x" exit
#for x in 13.91.47.76 40.85.190.91 52.187.75.218 52.174.163.213 52.237.203.198;
#do   ip_portopen=$(echo > /dev/tcp/$x/443 && echo "$x port 443 is open.") ;
#       if [ $ip_portopen -eq 0 ] ;then
#       echo "Path to $x is failing. Please mitigate before running this script again."&& exit;
#       fi
#done

}


rhel6(){
        echo "RHEL 6"
        yum --config='https://rhelimage.blob.core.windows.net/repositories/rhui-microsoft-azure-rhel6.config' install 'rhui-azure-rhel6'
}

rhel7(){
        echo "RHEL 7"
        yum --config='https://rhelimage.blob.core.windows.net/repositories/rhui-microsoft-azure-rhel7.config' install 'rhui-azure-rhel7'
}

rhel8() {
echo "RHEL 8"

cat << EOF > rhel8.config
[rhui-microsoft-azure-rhel8]
name=Microsoft Azure RPMs for Red Hat Enterprise Linux 8
baseurl=https://rhui-1.microsoft.com/pulp/repos/microsoft-azure-rhel8 https://rhui-2.microsoft.com/pulp/repos/microsoft-azure-rhel8 https://rhui-3.microsoft.com/pulp/repos/microsoft-azure-rhel8
enabled=1
gpgcheck=1
gpgkey=https://rhelimage.blob.core.windows.net/repositories/RPM-GPG-KEY-microsoft-azure-release sslverify=1
EOF

        dnf --config rhel8.config install 'rhui-azure-rhel8';
        sudo dnf update
}

checknetwork;

if  grep -q -i "release 6" /etc/redhat-release ; then
        rhel6;
elif grep -q -i "release 7" /etc/redhat-release ; then
        rhel7;
elif grep -q -i "release 8" /etc/redhat-release ; then
        rhel8;
else
        echo "I do not find a version of Red Hat that matches Microsoft guidance for Azure VMs!"
fi


