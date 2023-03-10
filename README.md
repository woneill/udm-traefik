# Traefik Hostnames for Ubiquiti UbiOS firmwares

## Overview

This script supports dynamically discovering a Traefik server's HTTP router `Host` rules and adding DNS entries matching them to the Traefik server's IP address.

## Installation

1. Copy the contents of this repo to your device at `/data/udm-traefik`.
2. Edit `udm-traefik.env` and tweak variables to meet your needs.
3. Run `/data/udm-traefik/udm-traefik.sh`. This will handle your initial update of Traefik hostnames and setup a cron task at `/etc/cron.d/udm-traefik` to attempt refreshing the list each morning at 0300.

## Persistance

On firmware updates or just reboots, the cron file (`/etc/cron.d/udm-traefik`) gets removed, so if you'd like for this to persist, I suggest so you install boostchicken's [on-boot-script](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script) package.

This script is setup such that if it determines that on-boot-script is enabled, it will set up an additional script at `/data/on_boot.d/99-udm-traefik.sh` which will attempt Traefik hostnames generation shortly after a reboot (and subsequently set the cron back up again).

## Known Limitations

It is assumed that the Traefik API is not authenticated. Which normally would be a "bad thing" but the use case here is assuming that the Traefik server and services themselves are only exposed on the local network (i.e. one's home network)

## Inspiration

The structure of this project was inspired by the [Let's Encrypt support for Ubiquiti UbiOS firmwares](https://github.com/kchristensen/udm-le) project
