# Obraz dockerowy do części BE

## Budowa

```sh
docker build -t wus-be .
```

## Uruchomienie

```sh
docker run --rm -d -p 8081:8081 -e DB_ADDRESS=172.17.0.1 -e DB_PORT=8082 wus-be
```
