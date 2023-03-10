#!/bin/sh

# Load Environment Variables
# shellcheck source=../udm-traefik.env
. /data/udm-traefik/udm-traefik.env

if [ ! -f "${CRON_FILE}" ]; then
	# Sleep for 5 minutes to avoid restarting
	# services during system startup.
	sleep 300
	sh "${UDM_TRAEFIK_PATH}"/udm-traefik.sh
fi
