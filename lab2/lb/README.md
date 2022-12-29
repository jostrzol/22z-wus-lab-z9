# Obraz dockerowy do części LB

## Budowa

```sh
docker build -t wus-lb .
```

## Uruchomienie

```sh
docker run --rm -d -p 8081:8080 \
    -e BE_READ_ADDRESS=172.17.0.3 -e BE_READ_PORT=8081 \
    -e BE_WRITE_ADDRESS=172.17.0.4 -e BE_WRITE_PORT=8081 \
    wus-lb
```
