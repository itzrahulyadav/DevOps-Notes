#Docker 

### Docker Volume

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

- Then you can use exec command to execute the command inside the running container like this `docker exec it <container> /bin/bash`

