#!/bin/ash

US_TYPE=${US_TYPE:-'server'}
US_USER=${US_USER:-'unison'}


if [ ${US_TYPE} == 'server' ]
then
	if [ ! "${US_SSHKEY_PUB}" ]
	then
		printf "You've not provided ssh public key into environment. Read the doc to configure image with mandatory values.\n"
		exit 128
	fi
	printf "Use image as server mode.\n"
	if [ ! -d /home/${US_USER}/.ssh ]
	then
		printf "Creation of user : ${US_USER}"
		adduser -h /home/${US_USER} -s /bin/ash -D ${US_USER}
		mkdir -p /home/${US_USER}/.ssh
		echo ${US_SSHKEY_PUB} >> /home/${US_USER}/.ssh/authorized_keys
		chown -R ${US_USER}: /unison-datas
		chown -R ${US_USER}: /home/${US_USER}/
		chmod 700 /home/${US_USER}/.ssh
		chmod 400 /home/${US_USER}/authorized_keys
	fi

	if [ ! -f /etc/ssh/ssh_host_ed25519_key ] || [ ! -f /etc/ssh/ssh_host_ed25519_key.pub ] || [ ! -f /etc/ssh/ssh_host_rsa_key ] || [ ! -f /etc/ssh/ssh_host_rsa_key.pub ]
	then
		ssh-keygen -A
	fi

	printf "To connect, please use user : ${US_USER} with provided ssh key"

	/usr/sbin/sshd -D -f /etc/ssh/sshd_config
else
	printf "To use as client, refer to image documentation.\n"
	exit 128
fi
