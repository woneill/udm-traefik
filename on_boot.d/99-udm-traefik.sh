#!/bin/sh

# Load Environment Variables
# shellcheck source=../udm-traefik.env
. /data/udm-traefik/udm-traefik.env

traefik()
{
	sleep 300
	sh "${UDM_TRAEFIK_PATH}"/udm-traefik.sh
}

traefik &
