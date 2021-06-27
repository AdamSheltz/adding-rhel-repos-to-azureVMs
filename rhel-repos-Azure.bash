#!/bin/bash
Azure_Global=("13.91.47.76" "40.85.190.91" "52.187.75.218" "52.174.163.213" "52.237.203.198")
Azure_US_Government=("13.72.186.193"  "13.72.14.155" "52.244.249.194")
Azure_Germany=("51.5.243.77" "51.4.228.145")
region=()

checknetwork(){
        echo -n "Checking path to Azure RHEL repos for cloud."
        for x in ${region[@]}; do
                if  TESTCONNECTION=$(echo > /dev/tcp/$x/443);
                    [[ $TESTCONNECTION -eq 0 ]]; then
                        echo "This VM can connect to $x via port 443."
                else
                        echo "There is a connectivity issue when trying to connect to $x. Exitting script."
                        echo "Please resolve for the following IP addresses. ${region[@]}"
                        exit

                fi;

        done
        checkVersionRHEL;
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


checkVersionRHEL(){
if  grep -q -i "release 6" /etc/redhat-release ; then
        rhel6;
elif grep -q -i "release 7" /etc/redhat-release ; then
        rhel7;
elif grep -q -i "release 8" /etc/redhat-release ; then
        rhel8;
else
        echo "I do not find a version of Red Hat that matches Microsoft guidance for Azure VMs!"
fi
}



case "$1" in
        global)
                region+="${Azure_Global[@]}"
                checknetwork;
        ;;
        usgovt)
                region+="${Azuer_US_Government[@]}"
                checknetwork;
        ;;
        germany)
                region+="${Azure_Germany[@]}"
                checknetwork;
        ;;
        *)
                echo -n "Please use $0 global, usgovt, or germany."
        ;;
esac
