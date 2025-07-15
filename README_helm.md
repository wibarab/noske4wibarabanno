## initial install 
```bash
helm install noske4wibarabanno --namespace noske4wibarabanno -f auto-deploy-values.yaml  ./auto-deploy-app
```


## later changes
```bash
helm upgrade --install noske4wibarabanno --namespace noske4wibarabanno -f auto-deploy-values.yaml  ./auto-deploy-app
```
