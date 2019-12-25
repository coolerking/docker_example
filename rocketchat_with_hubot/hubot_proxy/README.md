Proxy環境下でRocket.Chat用Hubotコンテナを作成するための Dockerfile
------

# 使い方

以下の変数が`ARG`定義されています。
これらのデフォルト値のまま使用すると、ほぼすべての環境でエラーとなります。

このため、`docker`コマンドや`docker-compose`コマンドの`--build-arg`オプションや、`docker-compose.yml`の`args:`にて値を上書き指定してください。

| `ARG`変数名 | デフォルト値 | 説明 |
|:-------------|:----------------|:---------|
| <code>HTTP_PROXY</code> | <code>http://proxy.server:8080</code> | PROXYサーバ(http)をURL指定します|
| <code>HTTPS_PROXY</code> | <code>http://proxy.server:8080</code> | PROXYサーバ(https)をURL指定します|

また、以下の変数がENV定義されています。
`ARG`変数同様、これらもデフォルト値のまま使用することはできません。

`docker`コマンドの`-e`や、`docker-compose.yml`ファイルの`environment:`などを使って、上書き指定してください。

| `ENV`変数名 | デフォルト値 | 説明 |
|:---------|:------------|:------|
| <code>BOT_NAME</code> | <code>bot</code> | 作成するHubotチャットボットの名前。ここで指定する値は、 **ログインユーザ名ではない** 。 |
| <code>BOT_OWNER</code> | <code>Change Your Name &lt;change@your.e.mail.address&gt;</code> | 作成するHubotチャットボットオーナ情報。通常は"氏名 <メールアドレス>"型式で指定する。 |
| <code>BOT_DESC</code> | <code>RocketChatBot for development</code> | 作成するHubotチャットボットの概要説明文。 |
| <code>ROCKETCHAT_URL</code> | <code>rocketchat:3000</code> | Rocket.Chatサーバおよびポートを指定する。 |
| <code>ROCKETCHAT_ROOM</code> | <code>general</code> | デフォルトで待機するルームを指定する。ダイレクトメッセージのみの場合は空文字を指定する。 |
| <code>ROCKETCHAT_USER</code> | <code>bot</code> | Hubotアカウントとして予めサーバ上に作成したRocket.Chatユーザ名。 |
| <code>ROCKETCHAT_PASSWORD</code> | <code>password</code> | Hubotアカウントとして予めサーバ上に作成したRocket.Chatユーザのログインパスワード。 |
| <code>ROCKETCHAT_AUTH</code> | <code>password</code> | Rocket.Chat側の認証方式。LDAPの場合は"ldap"と指定する。 |
| <code>LISTEN_ON_ALL_PUBLIC</code> | <code>true</code> | パブリックチャネルで待ち受けるかどうかを指定する。 |
| <code>EXTERNAL_SCRIPTS</code> | <code>hubot-diagnostics,hubot-help,hubot-google-images,hubot-google-translate,hubot-pugme,hubot-maps,hubot-redis-brain,hubot-rules,hubot-shipit,hubot-jenkins-notifier,hubot-grafana</code> | <code>external-scripts.json</code> へ指定する外部スクリプトのリスト。 |
| <code>TZ</code> | <code>Asia/Tokyo</code> | タイムゾーン。おそらく変更しないでよいはず。 |


## docker コマンド

エクサ社内LAN内で `webpot/hubot_proxy:latest` という名前でビルドする場合、以下のコマンドを実行します。

```
$ docker build --tag webpot/hubot_proxy:latest --build-arg HTTP_PROXY=http://solidproxy.exa-corp.co.jp:8080 --build-args HTTPS_PROXY=http://solidproxy.exa-corp.co.jp:8080 .
```

`webpot/hubot_proxy:latest` を、デーモン実行する場合は、以下のコマンドを実行します。

```
$ mkdir data && chmod a+rwx data
$ docker run --name hubot -v data:/home/hubot/scripts -p3001:8080 -d webpot/hubot_proxy:latest
```

上記コンテナのログを参照する場合は、以下のコマンドを実行します。

```
$ docker logs hubot
```

コンテナを停止する場合は、以下のコマンドを実行します。

```
$ docker stop hubot
```

強制停止したい場合は、`docker kill`コマンドを使用します。


また、独自のnodeパッケージをコンテナ上に導入したい場合は、以下のように`docker exec`コマンドを実行してシェルを実行してください。

```
you@hostmachine$ docker exec hubot bash
root@xxxxxxxxxx$ npm install.. ←docker execに成功するとプロンプトが変わる
...


root@xxxxxxxxxx$ exit ←exit実行で脱出できる
you@hostmachine$
```

## docker-compose コマンド

エクサ社内LAN内で`webpot/hubot_proxy:latest`という名前でビルドする場合、`Dockerfile`を配置するディレクトリを作成し、配置します。


```
$ mkdir hubot_proxy
$ cd hubot_proxy
..ftp などを使ってDockerfileを配置

$ cd ..
```

以下のようなYAML型式の`docker-compose.yml`ファイルを作成します。`Dockerfile`を配置したディレクトリの親ディレクトリに作成します。

```docker-compose.yml
version: '2.2'
services:
  hubot:
    build:
      context: ./hubot_proxy
      args:
        HTTP_PROXY: http://solidproxy.exa-corp.co.jp:8080
        HTTPS_PROXY: http://solidproxy.exa-corp.co.jp:8080
    environment:
      - ROCKETCHAT_URL=160.14.XX.YY:3000
      - ROCKETCHAT_ROOM=
      - ROCKETCHAT_USER=exabot
      - ROCKETCHAT_PASSWORD=exaexaexa
      - BOT_OWNER="Tasuku Hori <tasuku-hori@exa-corp.co.jp>"
      - BOT_NAME=exabot
      - BOT_DESC="EXA LAN development bot"
      - HTTP_PROXY=http://solidproxy.exa-corp.co.jp:8080
      - HTTPS_PROXY=http://solidproxy.exa-corp.co.jp:8080
    links:
      - rocketchat:rocketchat
    labels:
      - "traefik.enable=false"
    volumes:
      - ./data:/home/hubot/scripts
      - /etc/localtime:/etc/localtime:ro
    ports:
      - 3001:8080
```

上記設定の場合、「http://160.14.XX.YY:3000」でログイン可能なRocket.Chatサーバには「exabot」ユーザでパスワード「exaexaexa」でログインできるようになっている状態にしておく必要があります。

hubotコンテナを起動する場合は、初回のみ以下のコマンドを実行します。

```
$ docker-compose up -d hubot
```

停止する場合は、以下のコマンドを実行します。

```
$ docker-compose stop hubot
```

コンテナの状態を確認したい場合は、以下のコマンドを実行します。

```
$ docker-compose ps
```

hubotコンテナを2回目以降起動する場合は、以下のコマンドを実行します。

```
$ docker-compose start hubot
```

hubotコンテナのログを確認したい場合は、以下のコマンドを実行します。

```
$ docker-compose logs hubot
```

Docker Compose で起動したコンテナは、`docker`コマンドでも管理できますが、できるだけ`docker-compose`を使用して管理したほうが手数も少なくなります。


hubotコンテナ上に追加パッケージ投入のために、個別に`npm`を実行したい場合は、以下のコマンドをつかってシェル実行してください。

```
you@hostmachine$ docker-compose exec hubot bash
root@xxxxxxxxxx$ npm install.. ←execに成功するとプロンプトが変わる
...


root@xxxxxxxxxx$ exit ←exit実行で脱出できる
you@hostmachine$

```
