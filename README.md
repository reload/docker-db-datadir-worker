# Obsoleted

This project isn't used anymore, datadirs are made by https://github.com/reload/docker-db-datadir-builder triggered by https://github.com/reload/db-dump-worker these days.

# docker-db-datadir-worker
Pre-initializes datadirs for mariadb containers


## Setting up a new job
* If you want to use an init sql-script, place it under jobs/<jobname>/datadir-preinit-sanitize.sql (the filename can be whatever you want)
* Add a new cron-job configuration to etc/cron.d - first 4 digits should be the time the job should run. Sample configuration:
```
30 2 * * * root (. /etc/container_environment.sh && cd /opt/datadir-preinit && BASE_IMAGE=mariadb:10 ./preinit-tag.sh reload/spejderneslejr:db-data-test reload/spejderneslejr:db-datadir-test ../jobs/spejderneslejr/datadir-preinit-sanitize.sql) 2>&1 | /usr/bin/logger -t datadir-preinit:spejderneslejr
```

Steps of execution
1. source /etc/container_environment.sh
2. Change cwd to /opt/datadir-preinit
3. Set the BASE_IMAGE environment to a maria-db image if you want to build a full database-image instead of just an image with the datadir
4. Execute preinit-tag.sh <source-db-dump-image> <target-datadir-image> [full-path-to-initscript]
