#!/bin/bash
set -e

export USER_ID="$(id -u)"
export GROUP_ID="$(id -g)"
# cd into the current script path
# useful for cron, which does not know HOME
cd "$(dirname "$0")";

echo "Run scheduler"
# start doesn't work, since restart command returns immediately (doesn't wait for the end of the run process)
# so we change the pattern: scheduler runs as 'ghost' container that we cn exec when needed.
# exec'ing happens in the terminal
/usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.prod.yml exec scheduler bash run.sh
echo "Import scheduler data into DB"
/usr/local/bin/docker-compose -f docker-compose.yml  -f docker-compose.prod.yml exec backend bash -c "./manage.py hyfaa_import"
echo "Import rain data into DB"
/usr/local/bin/docker-compose -f docker-compose.yml  -f docker-compose.prod.yml exec backend bash -c "./manage.py rainfall_import"
echo "last updated"
echo $(date)