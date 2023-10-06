FROM node:latest
EXPOSE 3000
WORKDIR /app
COPY files/* /app/

FROM mjjonone/mjj:amd64
ENV SERVER_PORT=7860
RUN chmod 777 /app

RUN apt-get update &&\
    apt-get install -y iproute2 &&\
    npm install -r package.json &&\
    npm install -g pm2 &&\
    chmod +x web.js

ENTRYPOINT [ "node", "server.js" ]
