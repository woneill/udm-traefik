#!/bin/sh

set -e

# Load environment variables
# shellcheck source=udm-traefik.env
. /data/udm-traefik/udm-traefik.env

generate_traefik_hosts() {
    API_REQUEST=$(curl -fsSL --resolve "${TRAEFIK_HOSTNAME}:${TRAEFIK_API_PORT}:${TRAEFIK_IPADDRESS}" https://"${TRAEFIK_HOSTNAME}"/api/http/routers)
    res=$?
    if test "$res" != "0"; then
        echo "the curl command failed with: $res"
        exit 1
    fi

    echo "${API_REQUEST}" | jq -r --arg TRAEFIK_IPADDRESS "${TRAEFIK_IPADDRESS}" \
        '.[] | ( .rule | capture("(?<host>(?<=`).+(?=`))") | "host-record=" + .host + "," + $TRAEFIK_IPADDRESS )' | \
    sort | uniq > "${UDM_TRAEFIK_PATH}"/traefik_hosts
    res=$?
    if test "$res" != "0"; then
        echo "the jq command failed with: $res"
        exit 1
    fi

    # Ensure reverse lookup returns the Traefik server hostname
    echo "${TRAEFIK_IPADDRESS}" | awk -v TRAEFIK_HOSTNAME="${TRAEFIK_HOSTNAME}" -F. '{printf "ptr-record=%d.%d.%d.%d.in-addr.arpa.,%s", $4, $3, $2, $1, TRAEFIK_HOSTNAME}' >> "${UDM_TRAEFIK_PATH}"/traefik_hosts
}

restart_dnsmasq() {
    # Reload DNSMasq to pickup our changes
    if [ -f /run/dnsmasq.pid ]; then
        kill -9 "$(cat /run/dnsmasq.pid)"
    fi
}

# Setup persistent on_boot.d trigger
if [ -d "${ON_BOOT_DIR}" ] && [ ! -f "${ON_BOOT_DIR}/${ON_BOOT_FILE}" ]; then
	cp "${UDM_TRAEFIK_PATH}/on_boot.d/${ON_BOOT_FILE}" "${ON_BOOT_DIR}/${ON_BOOT_FILE}"
	chmod 755 "${ON_BOOT_DIR}"/"${ON_BOOT_FILE}"
fi

# Setup cron job
if [ ! -f "${CRON_FILE}" ]; then
	printf 'MAILTO=""\n0 3 * * * root %s/udm-traefik.sh' "${UDM_TRAEFIK_PATH}" > "${CRON_FILE}"
	chmod 644 "${CRON_FILE}"
	/etc/init.d/cron reload "${CRON_FILE}"
fi

generate_traefik_hosts \
    && ! diff -N "${DNSMASQ_CONF_DIR}"/traefik_hosts "${UDM_TRAEFIK_PATH}"/traefik_hosts \
    && mv "${UDM_TRAEFIK_PATH}"/traefik_hosts "${DNSMASQ_CONF_DIR}"/traefik_hosts \
    && restart_dnsmasq
