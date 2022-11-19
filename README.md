# WUS Lab zespół 9

Skrypt `main.sh`

## Zależności skryptu

* `az`
* `jq`

## Parametry skryptu

* --config NR_CONFIGU - wybór zadania
* --fe NAZWA_VM PORT_FE - konfiguracja FE
* --be NAZWA_VM PORT_BE - konfiguracja BE
* --db NAZWA_VM PORT_DB - konfiguracja DB

Powtarzanie tej samej `NAZWA_VM` oznacza deployment na tę samą maszynę.

## Przykłady użycia skrytpu

Wdrożenie na 3 maszyny (nazwane vm1, vm2, vm3)

```sh
./main.sh --config 1 --fe vm1 80 --be vm2 9967 --db vm3 1434
```

Wdrożenie na 2 maszyny (nazwane vm1, vm2, vm3)

```sh
./main.sh --config 1 --fe vm1 80 --be vm1 9967 --db vm2 1434
```

## Pomocniczy skrypt cleanup.sh

Skrypt pozwala na wyczyszczenie wszystkich zasobów stworzonych przez `cleanup.sh`.