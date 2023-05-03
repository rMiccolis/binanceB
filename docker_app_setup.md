# -------------------------------------------------------------------------------------------------------------
# DOCKER APPLICATION SETUP:

1. position in the root directory (./binanceB)

2.  create docker build:
    ```
    sudo docker build -t rmiccolis/binanceb_nodejs_server -f ./server/server.dockerfile ./server/
    ```
    create docker client build:
    ```
    sudo docker build -t rmiccolis/binanceb_vuejs_client -f ./client/client.dockerfile ./client/
    ```
#### if debug is needed while building:
#### create build and debug (example):
    ```
    sudo docker build --no-cache --progress=plain -t rmiccolis/binanceb_vuejs_client -f ./client/client.dockerfile ./client/
    ```
3. push images to Docker Hub:
    ```
    sudo docker push rmiccolis/binanceb_nodejs_server:NOMETAG
    sudo docker push rmiccolis/binanceb_vuejs_client:NOMETAG
    ```

# Instructions to run on ('plain') docker
```
run docker server build: docker run --rm --name server -d -p 3000:3000 server
run docker client build: docker run --rm --name client -d -p 8081:80 client

# create docker volume: 
docker volume create --name mongodb_volume

# create docker mongodb build: 
docker run --rm --name mongodb -d -p 27018:27017 -v mongodb_volume:/data/db mongo
```
