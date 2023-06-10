# Docker 
Docker is a tool that helps in developing building,deploying and executing software in isolatation.It does so by creating containers that completely wrap a  software.

# What is a Container ?

Contaiener are softwares that wrap up all the parts of a code and all its dependencies into a single deployable unit that can be used on different systems and servers.

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

```

- Create a folder in your local machine and use it inside of the container.

```
mkdir myvol

docker run -v $(pwd)/myvol:/myvol -itd <image_name>

```

- Then you can use exec command to execute the command inside the running container like this `docker exec it <container-hashcode> /bin/bash`



