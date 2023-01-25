# Tworzenie klastra za pomocą terraform

Pliki konfiguracyjne terraform i instrukcja brane i zmodyfikowane z [instrukcji Azure](https://learn.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks).

## Instrukcja

Przed tworzeniem klastra konieczne jest bycie zalogowanym w Azure cli i posiadanie pary kluczy SSH (ścieżka do klucza publicznego w konfiguracji jest w **variables.tf** przy zmiennej "ssh_public_key" ).

Klucze ssh można stworzyć poleceniem 
```bash
ssh-keygen -m PEM -t rsa -b 4096
```
W folderze z terraform do pobrania odpowiednich modułów używamy
```bash
terraform init
```
Tworzymy plan wykonania terraform
```bash
terraform plan -out main.tfplan
```
Odpalamy nasz plan wykonania
```bash
terraform apply main.tfplan
```
Zapisujemy konfigurację kubernetes w **azurek8s**
```bash
echo "$(terraform output kube_config)" > ./azurek8s
```
Jeśli mamy **<<EOT** na początku pliku **azurek8s**, a końcu mamy **EOT**, usuwamy je

## Usuwanie grupy zasobów z Azure

Za pomocą poniższej komendy możemy stworzyć plan usunięcia
```bash
terraform plan -destroy -out main.destroy.tfplan
```

Tak usuwamy nasze zasoby z Azure
```bash
terraform apply main.destroy.tfplan
```
## Przydatne instrukcje

Listujemy wartości wyjściowe terraforma za pomocą
```bash
terraform output
```

Odczytujemy je za pomocą
```bash
echo "$(terraform output <nazwa_wartości>)"
```

Zapisujemy nasz plik kofiguracyjny jako zmienną za pomocą
```bash
export KUBECONFIG=<ścieżka_do_azurek8s>
```




