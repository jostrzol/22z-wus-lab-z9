
```sh
kubectl get deployment -n spring-petclinic
```

```sh
kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName -n spring-petclinic
 ```