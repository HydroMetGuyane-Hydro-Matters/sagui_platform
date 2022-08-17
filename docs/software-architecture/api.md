# API Backend

L'API (Application Programming Interface) fournit l'accès aux services de données de la plate forme, à l'exception des services Vector Tiles.

Plusieurs accès à l'API sont possibles :
- API navigable (hyperlinked), sur [https://sagui.hydro-matters.fr/api/v1/](https://sagui.hydro-matters.fr/api/v1/)
- interface Swagger/OpenAPI v3 sur [https://sagui.hydro-matters.fr/api/schema/swagger-ui/](https://sagui.hydro-matters.fr/api/schema/swagger-ui/)
- Accès direct par requête GET, bien sûr, pour chacun des services.

## Services

### dashboard
[http://sagui.hydro-matters.fr/api/v1/dashboard](http://sagui.hydro-matters.fr/api/v1/dashboard)

Fournit les données nécessaires à l'affichage du dashboard/menu permettant de basculer entre les vues.

### Données de prévi

#### flow-previ-stations-list
[http://sagui.hydro-matters.fr/api/v1/flow_previ/stations](http://sagui.hydro-matters.fr/api/v1/flow_previ/stations)

Ce service est disponible aux formats suivants : 
- api : pour visualisation dans le navigateur (HTML)
- json
Pour le format json (geojson), il est possible de simplement suffixer l'URL : [http://sagui.hydro-matters.fr/api/v1/flow_previ/stations.json](http://sagui.hydro-matters.fr/api/v1/flow_previ/stations.json)

Fournit la liste des stations virtuelles au format geojson. Pour chaque station est fourni un champ `levels` contenant une liste d'enregistrements, avec pour chacun
- `date` de l'enregistrement
- `level` : niveau d'anomalie du débit. Il est utilisé pour fixer l'icône de la station, à afficher dans la carte. Les seuils sont codés en dur dans la base de données dans la fonction `guyane.anomaly_to_alert_level`:
```
   WHEN flow_anomaly < -50 THEN 'd3' 
   WHEN flow_anomaly < -25 THEN 'd2' 
   WHEN flow_anomaly < -10 THEN 'd1' 
   WHEN flow_anomaly > 50 THEN 'f3' 
   WHEN flow_anomaly > 25 THEN 'f2' 
   WHEN flow_anomaly > 10 THEN 'f1' 
   ELSE 'n'
```

- `source` : précise la source de la valeur. `forecast` pour les données de prévi, `assimilated` ou `mgbstandard` pour les données hyfaa (dépend de la donnée utilisée comme référence. Peut être configuré via [l'interface d'admin](http://sagui.hydro-matters.fr/admin) par une personne disposant des droits adaptés) 

Un attribut `url` fournit le lien vers le service de données de la station, ex. [http://sagui.hydro-matters.fr/api/v1/flow_previ/stations/1/data](http://sagui.hydro-matters.fr/api/v1/flow_previ/stations/1/data)

#### Service de données (par station)
L'URL inclut l'identifiant de la station (attention, pas le minibasin correspondant, mais le champ `id` de la station)
Ex. [http://sagui.hydro-matters.fr/api/v1/flow_previ/stations/1/data](http://sagui.hydro-matters.fr/api/v1/flow_previ/stations/1/data)

Ce service est disponible aux formats suivants : 
- api : pour visualisation dans le navigateur (HTML)
- json
- CSV
Pour les formats json ou CSV, il est possible de simplement suffixer l'URL : [http://sagui.hydro-matters.fr/api/v1/flow_previ/stations/1/data.json](http://sagui.hydro-matters.fr/api/v1/flow_previ/stations/1/data.json) ou [http://sagui.hydro-matters.fr/api/v1/flow_previ/stations/1/data.csv](http://sagui.hydro-matters.fr/api/v1/flow_previ/stations/1/data.csv)

Il s'agit des données qui seront utilisées pour le graphique, lors d'un clic sur la station. L'attribut `data` contient les données suivantes
- `flow` : liste des données de débit (source `assimilated` ou `mgbstandard` selon la config en BD). La liste couvre par défaut les 10 derniers jours. Il est possible de changer la durée via le paramètre GET `duration`. Chaque entrée contient les valeurs suivantes : 
  - `source`
  - `date`
  - `flow` (`median` si assimilated, `mean` si mgbstandard)
  - `flow_mad` ([MAD](https://en.wikipedia.org/wiki/Median_absolute_deviation) du débit)
- `forecast` : même chose, pour les données de prévi disponibles
- `references` : données de référence pré-changement climatique. Plusieurs périodes temporelles sont fournies. Pour chacune, les données de débit sont fournies pour les dates utiles pour ce graphique.




### Données de débit

#### flow-alerts-stations-list
[https://sagui.hydro-matters.fr/api/v1/flow_alerts/stations](https://sagui.hydro-matters.fr/api/v1/flow_alerts/stations)

Ce service est disponible aux formats suivants : 
- api : pour visualisation dans le navigateur (HTML)
- json
Pour le format json (geojson), il est possible de simplement suffixer l'URL : http://sagui.hydro-matters.fr/api/v1/flow_alerts/stations.json

Fournit la liste des stations virtuelles au format geojson. Pour chaque station est fourni un champ `levels` contenant une liste d'enregistrements, avec pour chacun
- `date` de l'enregistrement
- `level` : niveau d'alerte de débit. Des seuils, prédéfinis pour chaque station, déterminent ce code de niveau. Il est ensuite utilisé pour fixer l'icône de la station, à afficher dans la carte. Les seuils sont préinitialisés dans la base de données, et peuvent être modifiés manuellement via [l'interface d'admin](http://sagui.hydro-matters.fr/admin) par une personne disposant des droits adaptés. La fonction déterminant le niveau d'alerte est `guyane.func_stations_with_flow_alerts()`.

Un attribut `url` fournit le lien vers le service de données de la station, ex. [http://sagui.hydro-matters.fr/api/v1/flow_alerts/stations/1/data](http://sagui.hydro-matters.fr/api/v1/flow_alerts/stations/1/data)

#### Service de données (par station)
L'URL inclut l'identifiant de la station (attention, pas le minibasin correspondant, mais le champ `id` de la station)
Ex. [http://sagui.hydro-matters.fr/api/v1/flow_alerts/stations/1/data](http://sagui.hydro-matters.fr/api/v1/flow_alerts/stations/1/data)

Ce service est disponible aux formats suivants : 
- api : pour visualisation dans le navigateur (HTML)
- json
Pour le format json (geojson), il est possible de simplement suffixer l'URL : [http://sagui.hydro-matters.fr/api/v1/flow_alerts/stations/1/data.json](http://sagui.hydro-matters.fr/api/v1/flow_alerts/stations/1/data.json)

Il s'agit des données qui seront utilisées pour le graphique, lors d'un clic sur la station. L'attribut `data` contient les données suivantes
- `flow` : liste des données de débit (source `assimilated` ou `mgbstandard` selon la config en BD. La période couverte est 365j + la prévi par défaut. Il est possible de changer la durée via le paramètre GET `duration`. Chaque entrée contient les valeurs suivantes : 
  - `source`
  - `date`
  - `flow` (`median` si assimilated, `mean` si mgbstandard)
  - `flow_mad` ([MAD](https://en.wikipedia.org/wiki/Median_absolute_deviation) du débit)
  - `flow_expected` : valeur historique, obtenue par [médiane flottante](../algos/floating_median.md) autour de cette date, sur les années précédentes
- `forecast` : même chose, pour les données de prévi disponibles. Pas de valeur `expected`
- `thresholds` : Seuils d'alerte à afficher dans le graphique