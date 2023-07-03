# When the image is built on an Apple M1 chip
# it is necessary to specify an architecture
# that's compatible with Fargate,
# since that's what is being used in the
# Terrraform ECS configuration.

# Source of wisdom:
# https://www.padok.fr/en/blog/essential-container-error-ecs
FROM --platform=linux/amd64 node:alpine

# Un-comment the line below if the image
# the image is NOT intended to run on an  Apple M1.
# FROM node:alpine

WORKDIR /

COPY ./app/package.json /

RUN npm install

COPY ./app /

EXPOSE 80

CMD [ "npm", "start" ]

