#!/bin/bash
set -e

export USER_ID="$(id -u)"
export GROUP_ID="$(id -g)"
# cd into the current script path
# useful for cron, which does not know HOME
cd "$(dirname "$0")";
#ORANGE=$(tput setaf 3)
#NORMAL=$(tput sgr0) # taken from https://stackoverflow.com/questions/4332478/read-the-current-text-color-in-a-xterm/4332530#4332530
ORANGE=
NORMAL=

echo $(date +'%d-%m-%Y_%H:%M')

# disable tty mode in docker-compose
export COMPOSE_INTERACTIVE_NO_CLI=1

printf "${ORANGE}\n\n-------------------------------------------------\n"
printf "Run scheduler\n${NORMAL}"
# start doesn't work, since restart command returns immediately (doesn't wait for the end of the run process)
# so we change the pattern: scheduler runs as 'ghost' container that we cn exec when needed.
# exec'ing happens in the terminal
/usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.prod.yml exec -T scheduler bash run.sh

printf "${ORANGE}\n\n-------------------------------------------------\n"
printf "Import scheduler data into DB\n${NORMAL}"
/usr/local/bin/docker-compose -f docker-compose.yml  -f docker-compose.prod.yml exec -T backend bash -c "./manage.py hyfaa_import"

printf "${ORANGE}\n\n-------------------------------------------------\n"
printf "Import rain data into DB\n${NORMAL}"
/usr/local/bin/docker-compose -f docker-compose.yml  -f docker-compose.prod.yml exec -T backend bash -c "./manage.py rainfall_import"

# Atmo data
printf "${ORANGE}\n\n-------------------------------------------------\n"
printf "Atmo pollution data: Retrieve and process\n${NORMAL}"
/usr/local/bin/docker-compose -f docker-compose.yml  -f docker-compose.prod.yml exec -T atmo python atmo_process.py

# Send alerts
printf "${ORANGE}\n\n-------------------------------------------------\n"
printf "Sending alerts (emails)\n${NORMAL}"
/usr/local/bin/docker-compose -f docker-compose.yml  -f docker-compose.prod.yml exec -T backend bash -c "./manage.py rainfall_import"

printf "${ORANGE}\n\n-------------------------------------------------\n"
printf "last updated: \n${NORMAL}"
printf $(date +'%d-%m-%Y_%H:%M')
