## Network create for Hybris services
```bash
docker network create hybris-net --subnet=172.100.0.0/16 --gateway=172.100.0.1
```
## Build
```bash
docker build . -f mysql.Dockerfile -t mysql-hybris:5.7
```

## Run
```bash
docker run -d --name mysql-hybris -v /docker/hybris/db:/var/lib/mysql --network=hybris-net --ip 172.100.0.102 mysql:5.7
```

## Docker Build
```bash
docker build . -f hybris.Dockerfile -t hybris:1811
```

## Docker Run
```
docker run -it -d --name hybris-1811 -h hybris-1811 -v /app/hybris_docker/:/app/hybris/  --network=hybris-net --ip 172.100.0.101 -e RECIPE=local -e BRANCH_NAME=develop -e DEVELOPER_NAME="Dummy" -e DEVELOPER_EMAIL=dummy@dummy.com hybris:1811
```

```bash
docker exec -it hybris-1811 bash
cd ~
tail -f entrypoint.log
docker logs -f hybris-1811
```

```bash
docker stop hybris-1811 && docker rm hybris-1811 && docker rmi hybris:1811
```
