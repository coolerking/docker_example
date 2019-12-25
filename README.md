# Docker まわりのコード集

[Docker](https://www.docker.com/) を使った開発環境やプロジェクト運用サイトの作成を行う際に有用なDockerコードほかを公開しています。

> 全体的に古くなってしまったので、あくまで参考用として使用してください。

# コンテンツ

Dockerfileやdocker-compose.ymlサンプル集。一部IPアドレス修正が必要なものもあるので、いきなり立ち上げたりしないでください。

## [jenkins](http://pandagit.exa-corp.co.jp/89004/gifhub/tree/master/jenkins)

Jenkinsをdocker-composeであげる際に使用できるdocker-compose.ymlが入っています。Docker Composeであげるメリットは、再起動時コンテナ起動を不要にできることです。

## [mattermost](http://pandagit.exa-corp.co.jp/89004/gifhub/tree/master/mattermost)

試しに上げた、mattermost_previewです。おそらく現在はもっと新しいイメージが有ると思います。ご参考迄。

## [redmine](http://pandagit.exa-corp.co.jp/89004/gifhub/tree/master/redmine)

redmineを使用するプロジェクト用に作成したdocker-compose.ymlです。公式イメージではなく、星の多い公開イメージを使っています。

## [rocketchat](http://pandagit.exa-corp.co.jp/89004/gifhub/tree/master/rocketchat)

RocketChatコンテナだけ切り出したものです。ホスト側IPアドレスを書き換えて使ってください。

## [rocketchat_with_hubot](http://pandagit.exa-corp.co.jp/89004/gifhub/tree/master/rocketchat_with_hubot)

Hubot によるチャットボット開発用docker-compose.ymlです。

## [google_hangouts_nodered](http://pandagit.exa-corp.co.jp/89004/gifhub/tree/master/hangouts/nodered)

node-red 環境上に Google ハングアウトノードを追加したDockerfile。

## [selenium](http://pandagit.exa-corp.co.jp/89004/gifhub/tree/master/selenium)

Selenium Hub サーバ用のdocker-compose.ymlです。FireFoxとChromeの２つのノードも同時に立ち上がります。Testing用なのでバージョンが古いです。要注意。

## [tensorflow](http://pandagit.exa-corp.co.jp/89004/gifhub/tree/master/tensorflow)

転炉プロジェクトや海洋・IoTに提供した、TensorFlow 開発環境構築のためのスクリプトファイル群を提供しています。
スクリプト内で docker / nvidia-docker を呼び出しています。

> この環境は完全に古くなっているので使用しないでください

## [webpot](http://pandagit.exa-corp.co.jp/89004/gifhub/tree/master/webpot)

Docker Compose を使って、Redmine、Jenkins、RocketChat を実行するコンテナが記述されています。


# 備考

- [アプリ屋もドカドカDockerを使おう](https://www.slideshare.net/HoriTasuku/docker-docker-54012849)
