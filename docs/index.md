## SAGUI, Documentation technique

Ce site tente de documenter les aspects techniques liés à la réalisation du portail https://sagui.hydromatters.fr.

- [**architecture logicielle**](archi-logicielle.md)
- [**infrastructure serveur**](infra-serveur.md)
- **frontend** : pas encore réalisé. Les specifications du frontend sont dispo sur un [google doc](https://docs.google.com/document/d/1iTiXR6rnwC8uMJZPxX2lJjaUmzmbpoHbxUw-AYLWJVc/edit#)
- **backend** :
  - [**API**](api.md) : réalisée avec le framework django (python), c'est là que réside l'essentiel de la partie backend
  - **Vector tiles** : utilise [pg_tileserv](https://github.com/CrunchyData/pg_tileserv, avec une modification mineure (ajout d'un script qui attend la disponibilité de la BD avant de lancer pg_tileserv)
  - **BD** : Le choix est fait d'utiliser une image mainstream, pour simplifier les mises à jour et centraliser l'architecture technique sur le backend API. Il s'agit de postgis 3.2 sur postgresql 14.

