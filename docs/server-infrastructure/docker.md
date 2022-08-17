# Infrastructure dockerisée

Chacun des services web est encapsulé dans une image docker. ils sont assemblés via des fichiers docker-compose.

On peut assez facilement retrouver quelles images docker servent et comment, en analysant les fichiers docker-compose

## docker-compose.yml

La base de la composition. Définit : 
- database : base de données. Image mainstream postgis. Le dossier config/postgresql/entrypoint-initdb.d/ contient des fichiers d'initialisation de la base. Le reste est exécuté par le backend django au démarrage (création des tables, des vues et fonctions)
- backend : le backend django. Le code est dans le dossier sagui_backend. La quasi totalité de la structure de la BD est définie dans les migrations django, ce qui permet un suivi évolutif de la BD et une gestion centralisée. 
- nginx : utilisé pour servir les fichiers statiques de django. Rien de plus
- pg-tileserv-base : service transitionnel, uniquement présent pour faciliter la création de l'image pg-tileserv
- pg-tileserv : image pg-tileserv mainstream mais sous Alpine linux. La seule différence est l'ajout d'un fichier /wait-for-db.sh qui, comme son nom l'indique, force le conteneur à attendre que la BD soit disponible avant de démarrer
- varnish : sert à la fois de proxy (point d'entrée unique, redirige les requêtes vers le conteneur souhaité) et de serveur de cache. Cf [varnish-proxy.md](varnish-proxy.md).

Cette composition n'ouvre aucun accès (port). Il est donc nécessaire de rajouter une définition complémentaire, qui dépend du mode de fonctionnement (dev, prod).

## docker-compose.override.yml
Appliqué par défaut. C'est le mode *dev* : ouvre des ports pour accès aux services

Se lance (explicitement) avec 
```bash
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
```

## docker-compose.prod.yml
- Ajoute le service `scheduler` : utilisé pour lancer le processus hyfaa.
- Configure le service varnish un fonctionnement en production : 
  - configure son accès à un réseau qui doit être pré-existant et nommé `traefik-proxy_proxy_network`
  - ajoute les variables d'environnement traefik pour une résolution et une termination SSL via traefik.
  - un service traefik doit déjà être en fonctionnement sur le serveur. La configuration présente correspond à une config avec [https://github.com/OMP-IRD/traefik-proxy](https://github.com/OMP-IRD/traefik-proxy)
- Utilise des secrets pour toutes les données sensibles (mots de passe)

Se lance avec : 
```bash
USER_ID="$(id -u)" GROUP_ID="$(id -g)" docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```
