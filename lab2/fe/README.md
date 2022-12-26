# Obraz dockerowy do części FE

## Budowa

```sh
docker build -t wus-fe .
```

## Uruchomienie

```sh
docker run --rm -d -p 8080:80 -e BE_ADDRESS=localhost -e BE_PORT=8081 wus-fe
```
