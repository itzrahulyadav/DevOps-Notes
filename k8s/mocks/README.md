## Simple questions to practice k8s

1. Install etcd on a node.

```
ssh root@cluster2-controlplane

cluster2-controlplane ~ ➜ cd /tmp
cluster2-controlplane ~ ➜ export RELEASE=$(curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest | grep tag_name | cut -d '"' -f 4)
cluster2-controlplane ~ ➜ wget https://github.com/etcd-io/etcd/releases/download/${RELEASE}/etcd-${RELEASE}-linux-amd64.tar.gz
cluster2-controlplane ~ ➜ tar xvf etcd-${RELEASE}-linux-amd64.tar.gz ; cd etcd-${RELEASE}-linux-amd64
cluster2-controlplane ~ ➜ mv etcd etcdctl  /usr/local/bin/


```

2. Find the top nodes across all the cluster.

solution:
Check out the metrics for all node across all clusters:

```
kubectl top node --context cluster1 --no-headers | sort -nr -k4 | head -1

```

3. An etcd backup is already stored at the path /opt/cluster1_backup_to_restore.db on the cluster1-controlplane node. Use /root/default.etcd as the --data-dir and restore it on the cluster1-controlplane node itself.
You can ssh to the controlplane node by running ssh root@cluster1-controlplane from the student-node.

```

SSH into cluster1-controlplane node:

Install etcd utility (if not installed already) and restore the backup:

cluster1-controlplane ~ ➜ cd /tmp
cluster1-controlplane ~ ➜ export RELEASE=$(curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest | grep tag_name | cut -d '"' -f 4)
cluster1-controlplane ~ ➜ wget https://github.com/etcd-io/etcd/releases/download/${RELEASE}/etcd-${RELEASE}-linux-amd64.tar.gz
cluster1-controlplane ~ ➜ tar xvf etcd-${RELEASE}-linux-amd64.tar.gz ; cd etcd-${RELEASE}-linux-amd64
cluster1-controlplane ~ ➜ mv etcd etcdctl  /usr/local/bin/
cluster1-controlplane ~ ➜ etcdctl snapshot restore --data-dir /root/default.etcd /opt/cluster1_backup_to_restore.db 


```

4. Decode the existing secret called beta-sec-cka14-arch created in the beta-ns-cka14-arch namespace and store the decoded content inside the file /opt/beta-sec-cka14-arch on the student-node.

```
Look for the data in beta-sec-cka14-arch secret

student-node ~ ➜  kubectl get secret beta-sec-cka14-arch -o json --context cluster3 -n beta-ns-cka14-arch

you will find only one data entry in it called secret . Let's decode it and save output in /opt/beta-sec-cka14-arch file:

student-node ~ ➜  kubectl get secret beta-sec-cka14-arch --context cluster3 -n beta-ns-cka14-arch -o json | jq .data.secret | tr -d '"' | base64 -d > /opt/beta-sec-cka14-arch

```

5. 
There is an existing persistent volume called orange-pv-cka13-trb. A persistent volume claim called orange-pvc-cka13-trb is created to claim storage from orange-pv-cka13-trb.
However, this PVC is stuck in a Pending state. As of now, there is no data in the volume.
Troubleshoot and fix this issue, making sure that orange-pvc-cka13-trb PVC is in Bound state.

```

List the PVC to check its status
kubectl  get pvc
So we can see orange-pvc-cka13-trb PVC is in Pending state and its requesting a storage of 150Mi. Let's look into the events

kubectl get events --sort-by='.metadata.creationTimestamp' -A
You will see some errors as below:

Warning   VolumeMismatch            persistentvolumeclaim/orange-pvc-cka13-trb          Cannot bind to requested volume "orange-pv-cka13-trb": requested PV is too small
Let's look into orange-pv-cka13-trb volume

kubectl get pv
We can see that orange-pv-cka13-trb volume is of 100Mi capacity which means its too small to request 150Mi of storage.
Let's edit orange-pvc-cka13-trb PVC to adjust the storage requested.

kubectl get pvc orange-pvc-cka13-trb -o yaml > /tmp/orange-pvc-cka13-trb.yaml
vi /tmp/orange-pvc-cka13-trb.yaml
Under resources: -> requests: -> storage: change 150Mi to 100Mi and save.
Delete old PVC and apply the change:

kubectl delete pvc orange-pvc-cka13-trb
kubectl apply -f /tmp/orange-pvc--cka13-trb.yaml

```

6. It appears that the black-cka25-trb deployment in cluster1 isn't up to date. While listing the deployments, we are currently seeing 0 under the UP-TO-DATE section for this deployment. Troubleshoot, fix and make sure that this deployment is up to date.

```
Check current status of the deployment

kubectl get deploy 
Let's check deployment status

kubectl get deploy black-cka25-trb -o yaml
Under status: you will see message: Deployment is paused so seems like deployment was paused, let check the rollout status

kubectl rollout status deployment black-cka25-trb

You will see this message

Waiting for deployment "black-cka25-trb" rollout to finish: 0 out of 1 new replicas have been updated...
So, let's resume

kubectl rollout resume deployment black-cka25-trb
Check again the status of the deployment

kubectl get deploy 
It should be good now.

```

7. A new service account called thor-cka24-trb has been created in cluster1. Using this service account, we are trying to list and get the pods and secrets deployed in default namespace. However, this service account is not able to perform these operations.
Look into the issue and apply the appropriate fix(es) so that the service account thor-cka24-trb can perform these operations.


```
Check if this service account is associated with any role binding

kubectl get rolebinding -o yaml | grep -B 5 -A 5 thor-cka24-trb
You will see role-cka24-trb is associated with this SA. So let's edit it to see the permissions

kubectl edit role role-cka24-trb
Update it so that resourcesand verbs section look as below:

resources:
- pods
- secrets
verbs:
- list
- get

```

9.  The controlplane node called cluster4-controlplane in the cluster4 cluster is planned for a regular maintenance. In preparation for this maintenance work, we need to take backups of this cluster. However, something is broken at the moment!
Troubleshoot the issues and take a snapshot of the ETCD database using the etcdctl utility at the location /opt/etcd-boot-cka18-trb.db.
Note: Make sure etcd listens at its default port. Also you can SSH to the cluster4-controlplane host using the ssh cluster4-controlplane command from the student-node.

```

SSH into cluster4-controlplane host.
ssh cluster4-controlplane
Let's take etcd backup

ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /opt/etcd-boot-cka18-trb.db
It might stuck for forever, let's see why that would happen. Try to list the PODs first

kubectl get pod -A
There might an error like

The connection to the server cluster4-controlplane:6443 was refused - did you specify the right host or port?
There seems to be some issue with the cluster so let's look into the logs

journalctl -u kubelet -f
You will see a lot of connect: connection refused erros but that must be because the different cluster components are not able to connect to the api server so try to filter out these logs to look more closly

journalctl -u kubelet -f | grep -v 'connect: connection refused'
You should see some erros as below

cluster4-controlplane kubelet[2240]: E0923 04:38:15.630925    2240 file.go:187] "Could not process manifest file" err="invalid pod: [spec.containers[0].volumeMounts[1].name: Not found: \"etcd-cert\"]" path="/etc/kubernetes/manifests/etcd.yaml"
So seems like there is some incorrect volume which etcd is trying to mount, let's look into the etcd manifest.

vi /etc/kubernetes/manifests/etcd.yaml 
Search for etcd-cert, you will notice that the volume name is etcd-certs but the volume mount is trying to mount etcd-cert volume which is incorrect. Fix the volume mount name and save the changes. Let's restart kubelet service after that.

systemctl restart kubelet
Wait for few minutes to see if its good now.

kubectl get pod -A
You should be able to list the PODs now, let's try to take etcd backup now:

ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /opt/etcd-boot-cka18-trb.db


```

10. 
The yello-cka20-trb pod is stuck in a Pending state. Fix this issue and get it to a running state. Recreate the pod if necessary.
Do not remove any of the existing taints that are set on the cluster nodes.

```
Let's check the POD status
kubectl get pod --context=cluster2
So you will see that yello-cka20-trb pod is in Pending state. Let's check out the relevant events.

kubectl get event --field-selector involvedObject.name=yello-cka20-trb --context=cluster2
You will see some errors like:

Warning   FailedScheduling   pod/yello-cka20-trb   0/2 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/master: }, 1 node(s) had untolerated taint {node: node01}. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
Notice this error 1 node(s) had untolerated taint {node: node01} so we can see that one of nodes have taints applied. We don't want to remove the node taints and we are not going to re-create the POD so let's look into the POD config if its using any other toleration settings.

kubectl get pod yello-cka20-trb --context=cluster2 -o yaml
You will notice this in the output

tolerations:
  - effect: NoSchedule
    key: node
    operator: Equal
    value: cluster2-node01
Here notice that the value for key node is cluster2-node01 but the node has different value applied i.e node01 so let's update the taints values for the node as needed.
kubectl --context=cluster2 taint nodes cluster2-node01 node=cluster2-node01:NoSchedule --overwrite=true
Let's check the POD status again

kubectl get pod --context=cluster2

```


12.  A manifest file is available at the /root/app-wl03/ on the student-node node. There are some issues with the file; hence couldn't deploy a pod on the cluster3-controlplane node.
After fixing the issues, deploy the pod, and it should be in a running state.


```


```

13. There is a requirement to share a volume between two containers that are running within the same pod. Use the following instructions to create the pod and related objects:
- Create a pod named grape-pod-cka06-str.

- The main container should use the nginx image and mount a volume called grape-vol-cka06-str at path /var/log/nginx.

- The sidecar container can use busybox image, you might need to add a sleep command to this container to keep it running. Next, mount the same volume called grape-vol-cka06-str at the path /usr/src.

- The volume should be of type emptyDir.

12. Create a storage class with the name banana-sc-cka08-str as per the properties given below:

- Provisioner should be kubernetes.io/no-provisioner,

- Volume binding mode should be WaitForFirstConsumer.

- Volume expansion should be enabled.

13. Part I:
Create a ClusterIP service .i.e. service-3421-svcn in the spectra-1267 ns which should expose the pods namely pod-23 and pod-21 with port set to 8080 and targetport to 80.
Part II:
Store the pod names and their ip addresses from the spectra-1267 ns at /root/pod_ips_cka05_svcn where the output is sorted by their IP's.
```
student-node ~ ➜  kubectl create service clusterip service-3421-svcn -n spectra-1267 --tcp=8080:80 --dry-run=client -o yaml > service-3421-svcn.yaml
kubectl get pods -n spectra-1267 -o=custom-columns='POD_NAME:metadata.name,IP_ADDR:status.podIP' --sort-by=.status.podIP

```

14. 
Create a loadbalancer service with name wear-service-cka09-svcn to expose the deployment webapp-wear-cka09-svcn application in app-space namespace

```
 kubectl expose -n app-space deployment webapp-wear-cka09-svcn --type=LoadBalancer --name=wear-service-cka09-svcn --port=8080
service/wear-service-cka09-svcn exposed

```
15. Create a nginx pod called nginx-resolver-cka06-svcn using image nginx, expose it internally with a service called nginx-resolver-service-cka06-svcn.
Test that you are able to look up the service and pod names from within the cluster. Use the image: busybox:1.28 for dns lookup. Record results in /root/CKA/nginx.svc.cka06.svcn and /root/CKA/nginx.pod.cka06.svcn


```
To create a pod nginx-resolver-cka06-svcn and expose it internally:



student-node ~ ➜ kubectl run nginx-resolver-cka06-svcn --image=nginx 
student-node ~ ➜ kubectl expose pod/nginx-resolver-cka06-svcn --name=nginx-resolver-service-cka06-svcn --port=80 --target-port=80 --type=ClusterIP 



To create a pod test-nslookup. Test that you are able to look up the service and pod names from within the cluster:



student-node ~ ➜  kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn
student-node ~ ➜  kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service-cka06-svcn > /root/CKA/nginx.svc.cka06.svcn



Get the IP of the nginx-resolver-cka06-svcn pod and replace the dots(.) with hyphon(-) which will be used below.



student-node ~ ➜  kubectl get pod nginx-resolver-cka06-svcn -o wide
student-node ~ ➜  IP=`kubectl get pod nginx-resolver-cka06-svcn -o wide --no-headers | awk '{print $6}' | tr '.' '-'`
student-node ~ ➜  kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup $IP.default.pod > /root/CKA/nginx.pod.cka06.svcn


```
16. On student-node, use the command: kubectl create deployment hr-web-app-cka08-svcn --image=kodekloud/webapp-color --replicas=2
Now we can run the command: kubectl expose deployment hr-web-app-cka08-svcn --type=NodePort --port=8080 --name=hr-web-app-service-cka08-svcn --dry-run=client -o yaml > hr-web-app-service-cka08-svcn.yaml to generate a service definition file.
Now, in generated service definition file add the nodePort field with the given port number under the ports section and create a service.

```
On student-node, use the command: kubectl create deployment hr-web-app-cka08-svcn --image=kodekloud/webapp-color --replicas=2

Now we can run the command: kubectl expose deployment hr-web-app-cka08-svcn --type=NodePort --port=8080 --name=hr-web-app-service-cka08-svcn --dry-run=client -o yaml > hr-web-app-service-cka08-svcn.yaml to generate a service definition file.

Now, in generated service definition file add the nodePort field with the given port number under the ports section and create a service

```
