#!/bin/bash

# Generate SSH keys
for type in rsa dsa ecdsa ed25519; do
  if ! [ -e "/ssh/ssh_host_${type}_key" ]; then
    echo "/ssh/ssh_host_${type}_key not found, generating..."
    ssh-keygen -f "/ssh/ssh_host_${type}_key" -N '' -t ${type}
  fi

  ln -sf "/ssh/ssh_host_${type}_key" "/etc/ssh/ssh_host_${type}_key"
done

# Check if user exists, else create it
if ( id ${USER} ); then
    echo "INFO: User ${USER} is valid"
else
    echo "INFO: User ${USER} does not exist, creating it"
    ENC_PASS=$(perl -e 'print crypt($ARGV[0], "password")' ${PASS})
    useradd -d /data/${USER} -m -p ${ENC_PASS} -u ${USER_UID} -s /bin/sh ${USER}
    # Set ownership
    echo "INFO: Setting ownerships"
    chown root:root /data/${USER}
    find /data/${USER} -maxdepth 1 -type f -exec chown root:root {} +
fi

# Add group for sftp users and add USER to it, when it does not exists
GROUP_SFTP_NAME="sftp"
if ( getent group ${GROUP_SFTP_NAME} ); then
    echo "INFO: Group ${GROUP_SFTP_NAME} is valid"
else
    echo "INFO: Group ${GROUP_SFTP_NAME} does not exist, creating it"
    groupadd ${GROUP_SFTP_NAME}
    echo "INFO: Add user ${USER} to sftp group ${GROUP_SFTP_NAME}"
    usermod -a -G ${GROUP_SFTP_NAME} ${USER}
fi

# Validate group, else print a message
GROUP_NAME=$(cut -d: -f1 < <(getent group ${GROUP_GID}))
if ( getent group ${GROUP_GID} ); then
    echo "INFO: Group ${GROUP_NAME} is valid"
    
    # Check if user is in group, else add it
    if ( id -nG "${USER}" | grep -qw "${GROUP_NAME}" ); then
        echo "INFO: User ${USER} is in group ${GROUP_NAME}"    
    else
        echo "INFO: Adding user ${USER} to group ${GROUP_NAME}"
        usermod -a -G ${GROUP_NAME} ${USER}
    fi
else
    echo "INFO: Group ${GROUP_NAME} does not exist!"
fi

exec /usr/sbin/sshd -D
