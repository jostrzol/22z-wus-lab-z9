# Obraz dockerowy do części FE

## Budowa

```sh
docker build -t wus-fe .
```

## Uruchomienie

```sh
docker run --rm -d -p 8080:80 -e BE_ADDRESS=172.17.0.3 -e BE_PORT=8081 wus-fe
```
