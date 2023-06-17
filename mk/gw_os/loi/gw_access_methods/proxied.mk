#+
# Defines variables, targets, and functions for configuring an OS for proxied
# access.
#-

# This service file establishes a reverse tunnel with the proxy.
# This tunnel is used to transport other sessions established from the
# proxy.
define ProxyTunnelService
[Unit]
Description=Keep reverse tunnel to ${PROXY_URL} alive
After=network-online.target ssh.service

# Create a reverse tunnel with the proxy. This reverse tunnel can then
# be used to transport other protocols between the GW and a remote client.
[Service]
User=${GW_USER}
Restart=always
RestartSec=3
StartLimitIntervalSec=0
ExecStart=/usr/bin/ssh -NT -o ServerAliveInterval=30 -o ServerAliveCountMax=3 \
  -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=no \
  -i /home/${GW_USER}/.ssh/${PROXY_USER_KEY} \
  -R ${PROXY_TUNNEL_PORT}:localhost:${LOCAL_GW_PORT} \
  -p ${PROXY_SSH_PORT} \
  ${GW_PROXY_USER}@${PROXY_URL}
KillMode=process

[Install]
WantedBy=multi-user.target
endef

# This script runs as part of the first run initialization and installs
# the components needed to establish a reverse tunnel with the proxy.
define ProxyTunnelInitScript

endef

export ProxyTunnelService
export ProxyTunnelInitScript

ifeq (${MAKECMDGOALS},help-access-method)
define HelpAccessMethodMsg
Make segment: ${MCU_ACCESS_METHOD}.mk

This defines the variables, targets, and functions for configuring an OS for
proxied access.

A systemd service is created to automatically establish a reverse SSH tunnel
to the proxy. This service runs as the normal user who does not have admin
privileges.

All incoming ports are closed using a firewall. SSH login is not possible
except by way of the SSH tunnel to the proxy. The tunnel to the proxy can
then be used to transport other protocols. The tunnel can also used for software
deployment and remote administration.

In proxied systems all user names and keys are generated. Using generated
user names serves to enhance system security. A separate package called a
keyring provides the needed proxy credendials. This keyring contains
credentials for each of the allocated units identified by unit number. For
security reasons never disclose the contents of a keyring package. The
proxy keyring is downloaded from the proxy. This requires having a valid
proxy account to get started.

Scripts are generated to simplify connection to a remote device via the
proxy. Additional scripts are generated to simplify file transfer to and
from the remote device.

Required sticky command line options:
  GW_UNIT_NUMBER = ${GW_UNIT_NUMBER}
    This is a unit number assigned to an instance of the GW. This must be
	a valid and unique unit number from a previously allocated range.
  PROXY_USER = ${PROXY_USER}
    This is the user name assigned for downloading the keyring package.
  PROXY_KEY = ${PROXY_KEY}
    This is the key to use for downloading the keyring package for the GW.
  PROXY_SSH_PORT = ${PROXY_SSH_PORT}
    This is the port number to use for downloading the keyring package.
  PROXY_FQDN = ${PROXY_FQDN}
    This is the fully qualified domain name or IP address of the proxy.

Defined in mod.mk:

Defined in config.mk:

Defined in loi.mk (see help-loi):
  LOI_BUILD_PATH = ${LOI_BUILD_PATH}
  LOI_STAGING_PATH = ${LOI_STAGING_PATH}

Defines:
  PROXYED_GW_USER = ${PROXYED_GW_USER}
    This is the normal user. The user name is generated based upon the unit
	number and the proxy URL.
  PROXYED_GW_ADMIN = ${PROXYED_GW_ADMIN}
    This is the privileged user. The user name is generated based upon the unit
	number and the proxy URL.

Command line targets:
  help-access-method        Display this help.
  gen-proxied              Generate the necessary keys and support scrits.
  stage-proxied            Install the keys, service file, and scripts into
                            the OS image.
  clean-proxied            Remove the generated keys and scripts.

endef

export HelpAccessMethodMsg
help-access-method:
> @echo "$$HelpAccessMethodMsg" | less

endif # help-access-method
