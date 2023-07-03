## SAGUI, Documentation technique

Ce site tente de documenter les aspects techniques liés à la réalisation du portail https://sagui.hydromatters.fr.

- **Algorithmes**
  - [**Seuils d'alerte dans la carte**](algos/alerts.md)
- **Architecture logicielle** \
Sur le plan logiciel, la plate-forme se compose des éléments suivants : 
  - **frontend** : Définit l'interface utilisateur. Consomme les services fournis par l'API et les services carto (Vector Tiles)\
  Pas encore réalisé. Les specifications du frontend sont dispo sur un [google doc](https://docs.google.com/document/d/1iTiXR6rnwC8uMJZPxX2lJjaUmzmbpoHbxUw-AYLWJVc/edit#)
  - **backend** :
    - [**API**](software-architecture/api.md) : réalisée avec le framework django (python), c'est là que réside l'essentiel de la partie backend
    - **Vector tiles** : [le service de vector tiles](software-architecture/vt.md) fournit les données vectorielles de l'application au format MVT (MapBox Vector Tiles), pour consommation par le frontend. Ce sont les données affichées en mode vecteur dans l'application.
    - **Base de données** : Le choix est fait d'utiliser une image mainstream, pour simplifier les mises à jour et centraliser l'architecture technique sur le backend API. Il s'agit de postgis 3.2 sur postgresql 14. [La structure et les fonctions de la base de données](software-architecture/db.md) jouent un rôle primordial dans le portail.
- **Infrastructure serveur**
  - [**Infrastructure dockerisée**](server-infrastructure/docker.md)  : chacun des services web est encapsulé dans une image docker. ils sont assemblés via des fichiers docker-compose.
  - [**proxy et cache** varnish](server-infrastructure/varnish-proxy.md) 
  - [**certificat SSL** via traefik](server-infrastructure/traefik-proxy-and-ssl-termination.md) 

