# Obraz dockerowy do części DB

## Budowa

```sh
docker build -t wus-db .
```

## Uruchomienie

```sh
docker run --rm -d -p 8082:3306 wus-db
```
