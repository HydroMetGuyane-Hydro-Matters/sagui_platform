# SAGUI: Sig d’Alerte pour la Guyane sur l’eaU et l’aIr
This is the parent repo of the SAGUI demonstration portal.

[Technical documentation (in french)](https://hydrometguyane-hydro-matters.github.io/sagui_platform/)

## Build
You should be able to build the needed applications using docker-compose:
```bash
docker-compose build
```

## Run the apps
### Dev mode (localhost)
To start them in development mode, you can simply run
```bash
USER_ID="$(id -u)" GROUP_ID="$(id -g)" docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
```
Both `docker-compose.yml` and `docker-compose.override.yml` will be applied. Each service will open a port (5433, 8000, 7800). A varnish instance is put in front and should act as reverse-proxy, exposing them on port 80.
The available services are
- postgis DB on localhost:5433
- backend API. Swagger UI at http://localhost/api/schema/swagger-ui/
- vector tiles service, at http://localhost/tiles/. The interesting layer being the function `rain_cells_for_date`

### Production mode
It starts the hyfaa scheduler on startup, so you first need to configure it
**You first need to**
- put your hydroweb credentials in secrets/hydroweb_*.txt files (see [secrets/README.md](secrets/README.md))

To start them in production mode, the docker-compose.prod.yml applies a few modifications. Mostly, it is assuming that you have a [traefik reverse proxy](https://github.com/OMP-IRD/traefik-proxy) already running on the server and will configure the services to be exposed through this proxy.
```bash
USER_ID="$(id -u)" GROUP_ID="$(id -g)" docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```
The reasons why you should use those environment variables is explained just below in the section dedicated to the hyfaa scheduler. Of course, you can also set them once and for all in your profiles.rc file.


### Running the hyfaa scheduler
The hyfaa scheduler is the application that produces the data. It is configured in the docker-compose.yml to run as a 'ghost' container (sleeps and does nothing but staying available). Runs are to be scheduled, for instance using a cron task or run manually. You can run the following command to execute the hyfaa scheduler:
```bash
USER_ID="$(id -u)" GROUP_ID="$(id -g)" docker-compose exec -T scheduler bash run.sh
```
The variables allow to run the scheduler as the current user. Otherwise, the generated files will be owned by root, which can result unpractical.
The first scheduler run can take a long time, since it start from far back in time. Next runs are reasonably short.

There is no built-in CRON task to re-run the HYFAA scheduler. You'll have to run it manually (`docker-compose exec -T scheduler bash run.sh`) or program yourself a CRON task on your machine, running the same command.

#### Run the scheduler as current user
The scheduler is writing data in work_configurations. By default, it runs as
 root, which is then a mess to clean / manipulate.

 In docker-compose, the user is configured using USER_ID and GROUP_ID environment
  variables. By default, those variables are not set. You can set them
  * either in your .bashrc file
  * either before running the docker-compose command. For instance:

```bash
USER_ID="$(id -u)" GROUP_ID="$(id -g)" docker-compose ...
```

_**Note:**_ In a CRON task, env. vars defined in your .bashrc file are not
 available. It's better to use this form.


### importing data
When you first run the compo, the database will be created and populated with tables and functions, but there will be no data in it.
There are several data you will need to load into the DB. Those imports are not automated to prevent accidental removal of data

#### Importing MGB geospatial data (static data: import once)
The MGB process produces some geospatial data that are then used to display most of the processed data.

Those are:
- drainage data (*linear*)
- catchment data (minibasins, *polygons*)
- minibasins data (*point*)
- and stations, which is an additional dataset, stored initially in an excel sheet

Upon import, they go through several transformations. In the end, in the DB, it populates the tables:
- guyane.hyfaa_drainage (*linear*, with minibasin id)
- guyane.hyfaa_catchments (*polygon* with minibasin id and subbasin attribute)
- guyane.minibasins_data (non-geo table, with minibasin, subbasin, ordem, width and depth attributes)
- guyane.hyfaa_stations (*point*, with minibasin id, name, river name). This table is configured to be editable through the web admin interface, so be careful before replacing it (i.e. before running the import script again)

Importing those data is done by running:
```bash
docker-compose -f docker-compose.yml exec backend bash -c "POSTGRES_DB=sagui;POSTGRES_USER=postgres;export PGPASSWORD=sagui;cd /data;./publish.sh"
```
You might need to adapt a few elements to match your configuration (notably PGPASSWORD variable)

#### Importing reference data (static data: import once)
Those data are pre-global warming reference files, covering the stations. 
They can be imported by running
```bash
docker-compose -f docker-compose.yml  -f docker-compose.prod.yml exec backend bash -c "./manage.py stations_import_reference_data -p /data/stations/data_ref_2010-2020.csv"
```

#### Importing hyfaa netcdf data (dynamic data: import regularly to keep updated)
Hyfaa netcdf data are generated each time the hyfaa scheduler is run (ideally daily). To import the new data, you should run

```bash
docker-compose -f docker-compose.yml  -f docker-compose.prod.yml exec backend bash -c "./manage.py hyfaa_import"
```
It might take some time the first time, since there should be a few years of data to import. The later runs are incremental, unless you force to overwrite the records with the `-f` option.

#### Importing rainfall netcdf data (dynamic data: import regularly to keep updated)
Rainfall netcdf data are generated each time the hyfaa scheduler is run (ideally daily). To import the new data, you should run

```bash
docker-compose -f docker-compose.yml  -f docker-compose.prod.yml exec backend bash -c "./manage.py rainfall_import"
```
It might take some time the first time, since there should be a few years of data to import. The later runs are incremental, unless you force to overwrite the records with the `-f` option.

## CRON
To update the data using a cron task, a convenience script is provided: update_data.sh.
In your cron job, declare it with full path.

## HTTPS
A varnish instance is put in front to gather all behind the :80 port. But it does not handle https configuration. 
For this, you are expected to use an externally traefik instance, like https://github.com/OMP-IRD/traefik-proxy.

## About Sagui project

TODO TODO TODO

