# Gestion du certificat SSL et proxy frontal avec un traefik mutualisé

[Traefik](https://doc.traefik.io/traefik/) est un proxy http qui supporte notamment une configuration dynamique via des *labels* docker.

De ce fait, il se prête particulièrement bien au cas de figure où plusieurs plateformes doivent être hébergées sur un même serveur physique.

Nous installons donc séparément un service traefik sur notre serveur, en utilisant la config https://github.com/OMP-IRD/traefik-proxy. 

Ce service est ensuite utilisé via les labels définis dans docker-compose.prod.yml. Seul le conteneur varnish définit ces labels, ce qui signifie que tout passera par lui. Les requêtes http passeront donc par plusieurs étapes intermédiaires : 
- via traefik, avec une termination SSL
- puis via varnish avec 
  - une redistribution des requêtes, en fonction de leur pattern, vers un service ou un autre (tileserv, backend, frontend)
  - une mise en cache côté serveur, afin de limiter la charge sur les services de données