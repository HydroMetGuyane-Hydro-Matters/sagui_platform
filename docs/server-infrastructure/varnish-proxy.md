# Varnish : proxy et serveur de cache

La fonction principale de [varnish](https://docs.varnish-software.com/)  est la gestion du cache côté serveur. Via un fichier de config, on peut définir précisément les modalités de cache, en fonction des objects et URL requêtés. De facto, il fait aussi office de proxy, redirigeant les requêtes selon le motif de l'URL.

Afin de ne pas surcharger le serveur, les requêtes de l'API et des vector tiles sont stockées en cache par varnish : à chaque interrogation, varnish regarde s'il a une version valide en cache et la sert. Sinon, il la transmet au service référent et la stocke en cache. Pour une durée raisonnablement courte, afin de respecter l'aspect dynamique des données. Mais cela suffit à éviter d'exécuter plusieurs fois en parallèle une même requête dans la base de données.

La config se trouve dans config/varnish/default.vcl. La syntaxe n'est pas évidente. La durée de vie du cache est actuellement définie à 30s.