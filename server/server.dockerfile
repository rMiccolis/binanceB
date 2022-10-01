#Each instruction in this file creates a new layer
#Here we are getting our node as Base image
FROM node:latest
#Creating a new directory for app files and setting path in the container
RUN mkdir -p /usr/src/server
#setting working directory in the container
WORKDIR /usr/src/server
#copying the package.json file(contains dependencies) from project source dir to container dir
COPY package.json /usr/src/server/
# installing the dependencies into the container
RUN npm install
#copying the source code of Application into the container dir
COPY . /usr/src/server
#container exposed network port number
EXPOSE 3000
#command to run within the container
CMD ["node", "server.js"]