#!/bin/sh

# Load Environmnt Variables
# shellcheck source=../udm-traefik.env
. /mnt/data/udm-traefik/udm-traefik.env

if [ ! -f "${CRON_FILE}" ]; then
	# Sleep for 5 minutes to avoid restarting
	# services during system startup.
	sleep 300
	sh "${UDM_TRAEFIK_PATH}"/udm-traefik.sh
fi
