FROM node:8
MAINTAINER Tasuku Hori <tasuku-hori@exa-corp.co.jp>

# change your proxy with --build-arg options
ARG HTTP_PROXY=http://proxy.server:8080
ARG HTTPS_PROXY=$HTTP_PROXY

# node-red user home dir
RUN mkdir -p /usr/src/node-red

# User data directory, contains flows, config and nodes.
RUN mkdir /data

WORKDIR /usr/src/node-red

# root
RUN useradd --home-dir /usr/src/node-red --no-create-home node-red \
    && chown -R node-red:node-red /data \
    && chown -R node-red:node-red /usr/src/node-red \
    && npm -g config set proxxy $HTTP_PROXY \
    && npm -g config set https-proxy $HTTPS_PROXY \
    && npm -g config set registry http://registry.npmjs.org/ \
    && npm install -global coffeescript

USER node-red

# copy node-red user npm install
COPY package.json /usr/src/node-red/
RUN npm install

# port
EXPOSE 1880

# env
ENV FLOWS=flows.json
ENV NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules

CMD ["npm", "start", "--", "--userDir", "/data"]
