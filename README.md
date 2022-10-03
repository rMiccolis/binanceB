create docker server build: docker build -t server -f server.dockerfile .
create docker client build: docker build -t client -f client.dockerfile .

run docker server build: docker run --rm --name server -d -p 3000:3000 server
run docker client build: docker run --rm --name client -d -p 8081:80 client

create docker volume: docker volume create --name mongodb_volume

create docker mongodb build: docker run --rm --name mongodb -d -p 27018:27017 -v  mongodb_volume:/data/db mongo