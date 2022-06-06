#!/bin/bash

echo "Enter new port for Jenkins: "

read NEW_JENKINS_PORT

os_detect_command="cat /etc/os-release"

debian_path=lib/systemd/system/jenkins.service
rhel_suse_path=usr/lib/systemd/system/jenkins.service
arch_path=opt/jenkins/conf/wrapper.conf
freebsd_path=etc/rc.conf


port_change_debian_rhel_suse(){
    sudo sed -i "s/Environment=\"JENKINS_PORT=.*\"/Environment=\"JENKINS_PORT=${NEW_JENKINS_PORT}\"/" /$1
}


if ! echo $os_detect_command | grep "debian"; then
    echo "Distribution is Debian based"
    port_change_debian_rhel_suse ${debian_path}

elif ! echo $os_detect_command | grep "rhel"; then
    echo "Distribution is RHEL based"
    port_change_debian_rhel_suse ${rhel_suse_path}

elif ! echo $os_detect_command | grep "opensuse"; then
    echo "Distribution is openSUSE"
    port_change_debian_rhel_suse ${rhel_suse_path}

elif ! echo $os_detect_command | grep "arch"; then
    echo "Distribution is Arch based"
    sudo sed -i "s/wrapper.app.parameter.2=--httpPort=.*/wrapper.app.parameter.2=--httpPort=${NEW_JENKINS_PORT}/" /${arch_path}

elif ! echo uname -a | grep "FreeBSD"; then
    echo "System is FreeBSD"
    sudo sed -i "s/jenkins_args=\"--webroot=${jenkins_home}/war --httpPort=.*\"/jenkins_args=\"--webroot=${jenkins_home}/war --httpPort=${NEW_JENKINS_PORT}\"" /${freebsd_path}

fi



# Since source configuration of jenkins is changed we have to reload units through deamon

sudo systemctl daemon-reload

# Finally we have to restart jenkins.service and we're done with port change

sudo systemctl restart jenkins.service

echo "Jenkins port was changed to $NEW_JENKINS_PORT"

echo "Please change web config file on web server if you are using it."

echo "Location is probbably /etc/nginx/sites-available/ or /etc/apache/sites-aviliable"

echo "After change of web config you should also restart web server with command"

echo "sudo systemctl restaret nginx or sudo systemctl reload apache2 && sudo systemctl restart apache2"
