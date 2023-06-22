# Docker 
Docker is a tool that helps in developing building,deploying and executing software in isolatation.It does so by creating containers that completely wrap a  software.

# What is a Container ?

Containers are softwares that wrap up all the parts of a code and all its dependencies into a single deployable unit that can be used on different systems and servers.

Multiple isolated containers can be launched together to form microservices which can be easily managed using any orchestration tool. 
Eg - Docker swarm,Kubernetes etc.

Docker images are sets of instructions that are used to create containers and execute code inside it.

### Docker network 

A Docker network is basically a connection between one or more containers.One of the more powerfull things about the Docker containers is that they can be easily connected to one other and even other software,this makes it very easy to isolate and manage the containers.

### Docker Volume

Dockers are ephemeral in nature which means the moment you stop the container all its data is erased.So you need some sort of storage for 
storing and persisting data outside of containers.

Docker volumes are basically persistant storage locations for the containers.They can be easily and safely attached  and removed from different container and they are also portable from system to another.

- Create a volume

```
docker volume create myvol

```

- list volumes

```
docker volume ls
```
- inspect a volume

```
docker volume inspect <volume_name>

```

- Run a container and attach a volume

```
docker run -itd --name <name> --mount source=myvol.target=/vol <image_name>

```

- Run another container and use the same volume

```
docker run -itd --name <another_name> -v myvol:/vol <image_name>
// or

docker run -it --rm --mount source=my-volume,destination=<location inside container like /data> <image_name>

```

- Create a folder in your local machine and use it inside of the container.

```
mkdir myvol

docker run -v $(pwd)/myvol:/myvol -itd <image_name>

```

- Then you can use exec command to execute the command inside the running container like this `docker exec it <container-hashcode> /bin/bash`



## Docker Swarm

- use docker swarm init in the manager node 
- you wull recieve a command with token which can be used with docker to create docker swarm workers
- The command looks something like this 

```
docker swarm join --token SWMTKN-1-4ymm0j36p1v6nl2t0bn4vxazqtlehdogd5ir19hw9hf71wx5zt-es1ormjsg42etm9ldstij1umr 172.31.46.23:2377
```

- use docker info to get all the info
- use docker node ls to see the list of docker nodes
- use docker swarm leave to leave the swarm
- use  `docker swarm join-token worker `to get token which can be used to add workers to the swarm

#### Docker service
- Run the basic httpd container using the following command
 ```
 Docker service create  --name myservice --replicas 3 --publish 80:80 httpd
 
 ```
 - Replicas are the replicas of the service who are similar to each other

-  `docker service ls` is used to know the list of running services
- To see the list of running containers in a service use: `docker service ps <service name> `
- To remove the service use the command `docker service rm <service> `
- 
  

