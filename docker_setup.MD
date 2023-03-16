DOCKER APPLICATION SETUP:
-------------kubernetes-------------
position in the root directory

create docker server build: sudo docker build -t rmiccolis/binanceb_nodejs_server -f ./server/server.dockerfile ./server/
create docker client build: sudo docker build -t rmiccolis/binanceb_vuejs_client -f ./client/client.dockerfile ./client/

push images: docker push rmiccolis/binanceb_nodejs_server:NOMETAG
push images: docker push rmiccolis/binanceb_vuejs_client:NOMETAG
-------------kubernetes end-------------


run docker server build: docker run --rm --name server -d -p 3000:3000 server
run docker client build: docker run --rm --name client -d -p 8081:80 client

create docker volume: docker volume create --name mongodb_volume

create docker mongodb build: docker run --rm --name mongodb -d -p 27018:27017 -v mongodb_volume:/data/db mongo
