create docker server build: docker build -t server -f server dockerfile .

create docker volume: docker volume create --name mongodb_volume

create docker mongodb build: docker run --rm --name mongodb -d -p 27018:27017 -v  mongodb_volume:/data/db mongo