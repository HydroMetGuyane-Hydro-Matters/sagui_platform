#!/bin/bash
set -e

export USER_ID="$(id -u)"
export GROUP_ID="$(id -g)"
# cd into the current script path
# useful for cron, which does not know HOME
cd "$(dirname "$0")";

echo "Run scheduler"
docker-compose -f docker-compose.yml -f docker-compose.prod.yml restart scheduler
echo "Import scheduler data into DB"
docker-compose -f docker-compose.yml  -f docker-compose.prod.yml exec backend bash -c "./manage.py hyfaa_import"
echo "Import rain data into DB"
docker-compose -f docker-compose.yml  -f docker-compose.prod.yml exec backend bash -c "./manage.py rainfall_import"
echo "last updated"
echo $(date)