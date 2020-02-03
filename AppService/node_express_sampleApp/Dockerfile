FROM node:8
LABEL maintainer="Azure App Services Container Images <appsvc-images@microsoft.com>"

# Create app directory
WORKDIR /app

# Bundle app source
COPY . .

EXPOSE 8080 80
CMD [ "npm", "start" ]
