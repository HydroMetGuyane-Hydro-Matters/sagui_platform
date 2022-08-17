# Vector tiles
Le service de vector tiles fournit les données vectorielles de l'application au format MVT (MapBox Vector Tiles), pour consommation par le frontend. Ce sont les données affichées en mode vecteur dans l'application.

Il utilise [pg_tileserv](https://github.com/CrunchyData/pg_tileserv), avec une modification mineure (ajout d'un script qui attend la disponibilité de la BD avant de lancer pg_tileserv). 

Le service des vector tiles est accessible sur [https://sagui.hydro-matters.fr/tiles/](https://sagui.hydro-matters.fr/tiles/).

Les services particulièrement intéressants sont : 
- Prévisions : couche `guyane.hyfaa_forecast_aggregated_geo`
- Débits : couche `guyane.hyfaa_data_aggregated_geo`
- Pluviométrie : couche 'fonction' `guyane.mvt_rainfall`

Voir aussi la [documentation des tables et fonctions de la BD](db.md) pour le détail de ce que fournit chacune des couches listées sur [https://sagui.hydro-matters.fr/tiles/](https://sagui.hydro-matters.fr/tiles/).