FROM node:6.11
MAINTAINER Tasuku Hori <tasuku-hori@exa-corp.co.jp>

# change your setting or overwrite with build parameters
ARG HTTP_PROXY=http://proxy.server:8080
ARG HTTPS_PROXY=$HTTP_PROXY

USER root
RUN npm -g config set proxy $HTTP_PROXY && \
    npm -g config set https-proxy $HTTPS_PROXY && \
    npm -g config set registry http://registry.npmjs.org/ && \
    npm install -g yo generator-hubot && \
    npm install  -g hubot-rocketchat@1 && \
    useradd hubot -m
USER hubot
WORKDIR /home/hubot

# change your setting or overwrite command parameter
ENV ROCKETCHAT_URL=rocketchat:3000
ENV ROCKETCHAT_ROOM=general
ENV BOT_OWNER="Change Your Name <change@your.e.mail.address>"
ENV BOT_NAME=bot
ENV BOT_DESC="RocketChatBot for development"
ENV ROCKETCHAT_USER=bot
ENV ROCKETCHAT_PASSWORD=password
ENV ROCKETCHAT_AUTH=password
ENV LISTEN_ON_ALL_PUBLIC=true
ENV EXTERNAL_SCRIPTS=hubot-diagnostics,hubot-help,hubot-google-images,hubot-google-translate,hubot-pugme,hubot-maps,hubot-redis-brain,hubot-rules,hubot-shipit,hubot-jenkins-notifier,hubot-grafana
ENV TZ=Asia/Tokyo

RUN cd $HOME && \
    yo hubot --owner=$BOT_OWNER --name=$BOT_NAME --description=$BOT_DESC --adapter="rocketchat@1" && \
    node -e "console.log(JSON.stringify('$EXTERNAL_SCRIPTS'.split(',')))" > external-scripts.json && \
    npm install $(node -e "console.log('$EXTERNAL_SCRIPTS'.split(',').join(' '))")

EXPOSE 8080

CMD bin/hubot $BOT_NAME -a rocketchat
