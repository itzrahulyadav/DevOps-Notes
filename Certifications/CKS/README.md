## Certificates in kubernetes

- Different kubernetes components communicate with each other in sort of client server model and to facilitate this the components have their certificates.
- for e.g kube-apiserver has a server certificate and controller manager uses its client certificate to communicate with the kube-apiserver and same is for etcd and kubelet.

- we can check the list of certificates in `/etc/kubernetes/pki`
- etcd certificates are located in `/etc/kubernetes/pki/etcd`
- scheduler cert is located in `/etc/kubernetes/scheduler.conf`
- controller-manager certs are located in  `/etc/kubernetes/controller-manager.conf`
- kubelet conf file is located in `/etc/kubernetes/kubelet.conf` here the reference to `/var/lib/kubelet/pki` will be there

## containers

- As we all know containers are jut processes running in kernel.
- The following concepts/namespaces are used to isolate containers
    - PID = used to isolate processes from each other
    - Mount = used to restrict access to mounts or filesystems
    - Network = allows access to certain network devices,firewalls routing and port numbers
    - User = different set of user ids are used,a user in one namespace can have same user id in another namespace
    - cgroups = restricts the resource usage of processes

  
## securing linux host
- To create a new user with name Rahul and home directory /opt/rahul, login shell as /bin/bash,uid = 2328.Rahul must be a member of admin group


  ```
  useradd -d /opt/rahul -s /bin/bash -G admin -u 2328 Rahul

  ```

  - To allow a user to use sudo mode edit the /etc/sudoers
  ```
  - vi /etc/sudoers

  # add the following line
  - Rahul ALL=(ALL:ALL) ALL
  - Rahul ALL=(ALL) NOPASSWD:ALL
  

  ```

## open ports

- To black list a particular kernel module


```
- vi /etc/modprobe.d/blacklist.conf
- blacklist <module name>

```

## ServiceAccounts

- It's a non-human account used to provide limited access to Kubernetes resources.

- A default service account exists in each namespace.

## kubeconfig file

- we need to authenticate while making requests to kube-apiserver
- we can also communicate with kubernetes api using curl command and specifying the correct certificate files like this
  ```
  curl kubernetes:6443/pods \
  -- cert
  -- key
  -- 
  ```
  
- we do the same with kubectl `kubectl get pods --certfile --key --server` but instead of specifying explicitly we do it using a file called kubeconfig
- It is located at $HOME/.kube/config path and passed automatically while running kubectl commands if we want to use any other file or any other location we need to explicitly mention it `k get pods --kubeconfig=--my-kube-config`
- we can modify the kubeconfig file using kubectl commands `k config <>`.

## kubelet

- uses the port 10250 - serves api that allows full access
- uses the port 10255 - serves api that allows unauthenticated read only access
- we can set --anonymous-auth=false in kubelet config file to disable anonymous access
- we then need to authenticate to the kubelet to request and this can be done in two ways
       - certificates x509
       - bearer tokens
- so now we need to pass cert files when making requests to the kubelet `curl -sk https://localhost:10250/pods/ --key kubelet-key.pem --cert kubelet-cert.pem `
- The kube-apiserver is a client to the kubelet as it requests to the kubelet for the data so kube-apiserver also needs to authenticate to the kubelet for that kube-apiserver must have kubelet-client certificate and a key.

- -authorization mode must be set to webhook,doing so the kubelet makes request to the kube-apiserver to check the authorization of each request
- --read-only-port is set to 0 by default to prevent unauthorized access
- the config file can be checked at /var/lib/kubelet/config.yaml

## api-groups

- There are various api-groups and each api-group has a set of resources and each resource has a set of verbs associated with them.

## Anonymous access

- It allows anonymous access to the server
- --anonymous-auth must be set to false in kube-apiserver.yaml

## Insecure access

- Allows insecure access to the kube-apiserver
- Communication is done through http
- It bypasses authentication and authorization modules
- Admission controller still enforces
- --insecure-port=8080
- It should only be used for debugging

## Encryption configuration

- Allows to encrypt the etcd
- Create a encryption configuration file and pass it to kube-apiserver.

## Container runtime sandboxes

- containers run just like other linux processes in the kernel.
- If a process somehow manages to break out of container it can access all other processes running in the kernel.
- Containers use systemcalls (think of it like an api provided by kernel to processes to communicate with it) to interact with kernel.
- Sandboxes can be used to restrict the systemcalls of the containers
- We can use sandboxes to make the isolation layer more strong in the containers.
- Sandboxes are not free
- kernel version can be checked using uname -r (also strace uname -r)
- try dmesg to check the gvisor
  ### OCI
     - Linux foundation project to design open standards for virtualization
     - They define specification (image,distribution)
     - They define runtime (containerC)
 
## Runtimeclass

## SecurityContexts
- Defines privileges and access controls for pods/containers
- we can define
    - userid and groupid
    - linux capabilities
    - privileged and unprivileged
      
### runAsNonRoot,privileged,AllowPrivilegeEscalation
- It allows to run containers as non root user
- Using privileged mode the root user of the container is mapped to the root user of the host thereby providing more permissions
- AllowPrivilegeEscation controls whether the process can gain more privilege than its parent process

## admission controllers

- To check the admission controllers use the following command
  
- ```
   - k exec -it kube-apiserver-controlplane -- kube-apiserver -h | grep 'enable-admission-plugins'
  
  ```
- can be of type validating admission controllers and mutating admission controllers
- Admission webhook
## podSecurity

- podsecurity policy (deprecated)
  ### Pod Security Admission & Pod Security Standard
  - PSS defines three different security policies that cover a wide range of security needs
  - It has 3 profiles
     - Baseline (Minimal restrictive policy)
     - Privileged (unrestricted policy)
     - Restricted (Heavily restricted policy)
   
  
  - Pod Security Admission(PSA) operates in three modes to enforce the controls defined by PSS:
     - Enforce (Reject pod)
     - audit (Record in audit logs)
     - warn (Trigger user-facing warning)
   
  - Here's an example `pod-security.kubernetes.io/enforce: restricted`
    
## mTLS (mutual TLS)
- mutual authentication
- two parties can authenticate each other at the same time
- mTLS allow each pod to encrypt and decrypt traffic
- Most of the servicemesh use proxy containers which they run with the main container and allows connection with the pods

## Opa (open policy agent)
- It's an extension which can be installed on kubernetes to write custom policies
- It uses Rego to create policies
- It works with json/yaml
- It uses admission controllers
- It is integrated using opa gatekeeper which installs custom resource definitions(CRDs)
- It allows us to create custom templates and then using those templates we can create custom resources

## Image footprint

- Docker uses layers to build images
- We can use multi stage build to reduce our docker image size


## Image policy webhook

- It's used to ensure that images are pulled only from the secure registries
- we can create admission webhook server and make use of admission controllers to validate the requests
- for that we would need to create admissionconfiguration resource
- Once it is created we can configure kube-apiserver to use the admission controller using `--enable-admission-plugins=ImagePolicyWebhook`
- We also need to enable `--admission-control-config-file=/etc/kubernetes/admission-config.yaml`

## Manual analysis of files
- Tools like kubesec can be used
- CVE (common vulnerabilities and expolits) is a central database which containes info about the vulnerabilities
- We can make use of tool like trivy

## Hardening images

- use specific version of the base images
- run the container as non root
- make filesystem readonly 'RUN chmod a-w /etc'
- remove shell `rm -rf /bin/*`

## Static analysis

- Looks at the source code and text files
- check against rules
  ### static analysis rules
  - always define requests and limits
  - pod should never use the default service account
  - kubesec can be used for performing static analysis [Link](https://kubesec.io/)
  - conftest can be used by OPA
 
## Image vulnerabilities

- There are few tools which can scan our dockerfiles and docker images and can notify about the vulnerabilities.
- Some of them are clair and trivy

## supply chain

- We can use tools like OPA to put restriction on the images that we pull from the public/private registries
- We can create a secret of type docker registry to allow pulling images from the private registries and we also need to modify the serviceAccount to make it work.


## Host and container level vulnerabilities

- use the following [link](https://man7.org/linux/man-pages/man2/syscalls.2.html) to check the linux systemcalls
- strace is a tool which is used to intercept and logs systemcalls made by the processes
- used for debugging and diagnostic
- Here are some of the flags that can be used `-o filename -v verbose -f follow forks -cw (count and summarize) -p pid -P path`

  ### /proc directory
   - informations and connections to process and kernels
   - important for configurations and administration tasks
   - pstree can be used to see processes
   - we can check the secret data at /proc/<PID>/environ
     
  ### Falco
    - cloud native runtime security
    - deep kernel tracing built on kernel
    -  informs about the activities of a running container
    -  Rules can be changed in /etc/falco/falco_rules.local.yaml

## Immutability of containers at runtime

- delete the bash/sh
- make filesystem readonly (using securitycontext and podSecurityPolicies)
- run as nonroot user

## Audit logs
- History of api requests
- we can create audit rules to decide what data to store
- data will be most probably in Json format
- See the docs [here](https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/)
- Follow the following steps:
    - create an audit.yaml file
    - enable auditing in kube-apiserver
    - wait for the kube-apiserver to restart
    - If the api-server doesn't restart check the logs at `/var/log/pods/kube-system_kube-apiserver*`


## Linux kernel isolation

- The application/processes use systemcalls to talk to the kernel or maybe through packages
- The architecture is divided into user-space and kernel-space
- We can add an extra layer of security between the libraries/packages and the systemcalls made
- Apparmor and seccomp are some tools which can be used to secure kernel
   ### Apparmor
   - use the following [link] 
  (https://kubernetes.io/docs/tutorials/security/apparmor/#:~:text=Each%20profile%20can%20be%20run,better%20auditing%20through%20system%20logs.) for apparmor
   - To check the apparmor profile is enabled or not
     ```
       cat /sys/module/apparmor/parameters/enabled
     ```
   - just like seccomp apparmor uses profiles
   - To check the profiles
     ```
       cat /sys/kernel/security/apparmor/profiles

     ```
   ### Seccomp (secure computing mode)
  - By default linux kernel allows any process to call any systemcalls thereby increasing attack surface
  - seccomp allows to restrict the unnecessary calls
  - restrict execution of systemcalls
  - see the docs [here] (https://kubernetes.io/docs/tutorials/security/seccomp/)

## Encrypting secret data at rest

- Go through the following [docs](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/)

## Container sandboxing

- Sandboxing is a technology that isolates something from the rest of the system.
- Although we can use seccomp and apparmor for restricting the systemcalls made by the containers but it would become tedious to define different profiles when we are dealing with 100s of containers.
- Tools like gvisor and kata containers can be used to limit the systemcalls made by the containers.
- To run gvisor and other containers we need to use runtime class
- Read about it [here](https://kubernetes.io/docs/concepts/containers/runtime-class/)
  
