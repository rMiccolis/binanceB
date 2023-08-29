# build stage
FROM node:latest as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . ./
RUN npm run build

# production stage
# FROM nginx:latest as production-stage
# COPY --from=build-stage /app/dist /usr/share/nginx/html
# COPY --from=build-stage /app/dist/index.html /usr/share/nginx/html
# EXPOSE 8080
# CMD ["nginx", "-g", "daemon off;"]

FROM nginx:latest AS nginx
# COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build-stage /app/dist /usr/local/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;" ]