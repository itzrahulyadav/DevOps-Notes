## Helm

1. start by installing helm
    - snap install helm --classic
    - snap install tree

2. Create a helm chart `helm create demo`
3. See the structure using tree `/usr/bin/tree demo`
4. cd `demo/template` and delete everything `rm -rf *`
5. Create a configmap yaml

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: mychart-configmap
data:
  myvalue: "Hello Rebels"

```
7. use the dry run command to see the output  `helm install demo-chart --dry-run=client demo`
8. Modify the yaml file to add env variables

```
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: king-skeleton
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello Rebels"
```

9. Run the following command
```
helm install demo_chart demo

```
10. `helm get manifest king-skeleton`
11. That's it check the cm using  `k get cm --namespace`
