# https://blog.hypriot.com/post/microservices-bliss-with-docker-and-traefik/

# https://docs.traefik.io/configuration/backends/web/

# For API with auth
curl -u ${USER}:${PASSWORD} -sv "http://localhost:8080/api" | jq .

# For test ping
curl -sv "http://localhost:8081/ping"

# Commande docker

## Pour l'aide
docker --help

## Pour voir tous les dockers qui tournent
docker ps -a

# Commande docker-compose

## Pour l'aide
docker-compose --help
docker-compose <command> --help

## Pour lancer tous les containers
docker-compose up -d

## Pour lancer un container specifique
docker-compose up -d <container>

## Pour restart
docker-compose restart <container>

## Pour restart hard
docker-compose rm -sf <container> && docker-compose up -d <container>

## Pour arreter tous les containers
docker-compose down
