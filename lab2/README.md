# Laboratorium nr 2 - Ansible

## Obrazy

Obrazy do poszczególnych części wraz z ich dokumentacją znajdują się w katalogach: `fe/` , `be/` , `db/`

## Instalacja Ansible

```sh
python3 -m pip install --user ansible
```

## Konfiguracja Ansible

W pliku `inventory.yml` należy ustawić adresy do maszyn wirtualnych na których ma odbyć się deployment oraz ustawić odpowiednią konfigurację uruchomienia aplikacji (porty, adresy ich zależności itp.)

Również można ustawić ścieżki do kluczy ssh (`ansible_ssh_private_key_file`) uzyskanego w portalu Azure. (w przypdku problemów z zbyt otwartymi uprawnieniami należy ustawić `chmod 500` dla pliku z kluczem, a `chmod 700` dla katalogu nadrzędnego)

Aby sprawdzić, czy ansible jest w stanie połączyć się ze wskazanymi maszynami można wykorzystać następującą komendę:

```sh
ansible -m ping all
```

## Uruchomienie Ansible Playbook

```sh
ansible-playbook main_playbook.yml
```

Aby usprawnić działanie playbooka, można uruchomić tylko sekcję odpowiedzialną za redeployment aplikacji (jeśli wiemy że maszyna jest skonfigurowana tzn. ma zainstalowanego dockera):

```sh
ansible-playbook main_playbook.yml --tags "deploy"
```
