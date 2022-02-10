#!/bin/bash
# Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
# THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the 
# object code form of the Sample Code, provided that. You agree: (i) to not use Our name, logo, or trademarks to market Your 
# software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in 
# which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against
# any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code

#Variables/Arrays
Azure_Global=("13.91.47.76" "40.85.190.91" "52.187.75.218" "52.174.163.213" "52.237.203.198")
Azure_US_Government=("13.72.186.193"  "13.72.14.155" "52.244.249.194")
Azure_Germany=("51.5.243.77" "51.4.228.145")
region=()
RHELVERSION=$(cat /etc/redhat-release)

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
## https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/redhat/redhat-rhui#manual-update-procedure-to-use-the-azure-rhui-servers
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

testWget(){
# is wget already installed?
TESTWGET=$(wget github.com)
if [[  $? -eq 0 ]]; then
        echo "wget is installed"
else
        dnf install wget
        if [[ $? -eq 1 ]]; then
                echo "WGET not installed. Please rectify."
		exit 1 
        fi
fi
}

checkVersionRHEL(){

if  [[ "$RHELVERSION" ==  *"release 6"* ]]; then
        rhel6;
elif [[ "$RHELVERSION" == *"release 7"* ]] ; then
        rhel7;
elif [[ "$RHELVERSION" == *"release 8"* ]] ; then
        rhel8;
else
        echo "I do not find a version of Red Hat that matches Microsoft guidance for Azure VMs!"
fi
}

lock7(){
yum --disablerepo='*' remove 'rhui-azure-rhel7'
yum --config='https://rhelimage.blob.core.windows.net/repositories/rhui-microsoft-azure-rhel7-eus.config' install 'rhui-azure-rhel7-eus'
echo $(. /etc/os-release && echo $VERSION_ID) > /etc/yum/vars/releasever
echo "If there were no errors run 'sudo yum update'."
}

lock8(){
testWget;
yum --disablerepo='*' remove 'rhui-azure-rhel8'
wget https://rhelimage.blob.core.windows.net/repositories/rhui-microsoft-azure-rhel8-eus.config
yum --config=rhui-microsoft-azure-rhel8-eus.config install rhui-azure-rhel8-eus
echo $(. /etc/os-release && echo $VERSION_ID) > /etc/yum/vars/releasever
echo "If there were no errors run 'sudo yum update'."
}

versionLock(){
# https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/redhat/redhat-rhui
	echo "Locking version of RHEL to version: ."
	
	if [[ "$RHELVERSION" == *"release 7"* ]]; then
		lock7;
	elif [[ "$RHELVERSION" == *"release 8"* ]]; then
		lock8;
	else
		echo "I do not find a version of Red Hat for locking the REPOS for Microsoft guidance for Azure VMs!"
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
	versionlock)
		versionLock;
	;;
        *)
                echo -n "Please use $0 global, usgovt, or germany to add RHEL Repos or versionlock to Lock Repos to a version of RHEL."
        ;;
esac
