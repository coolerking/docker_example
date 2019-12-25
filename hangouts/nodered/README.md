# ハングアウトノードがインストールされた node-red コンテナ

ハングアウトへ接続するための node-red ノードが予め設定されている node-red コンテナです。
ハングアウト用チャットボットを作成する際に利用してください。

*注意* : 本サイトのDockerfileは *proxy環境下* での使用を前提としています。 *proxyなし* の環境での運用の場合は、 [こちら](https://nodered.jp/docs/platforms/docker) にしたがってください。

## 使い方

### イメージのビルド
```
git config --global --unset http.proxy
git config --global --unset https.proxy
export HTTP_PROXY=
export HTTPS_PROXY=
git clone http://pandagit.exa-corp.co.jp/git/89004/gifhub.git
cd gifhub/hangouts/nodered
sudo docker build . --tag node-red-hangouts --build-arg HTTP_PROXY=http://solidproxy.exa-corp.co.jp:8080  --build-arg HTTP_PROXY=http://solidproxy.exa-corp.co.jp:8080
```

### コンテナ初期起動
```
sudo docker run -d --name mynodered -p 1880:1880 node-red-hangouts
```

### node-red 開発画面を開く
ブラウザから「http://コンテナが起動しているマシンのIPアドレス:1880/」を開いてください。

* [node-red ドキュメント](https://nodered.jp/docs/)
  使い方などはこちらを参照してください。


### コンテナログ参照
```
sudo docker logs mynodered
```

### コンテナ停止
```
sudo docker stop mynodered
```

## コンテナ起動(2回目以降)

```
sudo docker start mynodered
```

### 動作中のコンテナをリスト
```
sudo docker ps
```


### コンテナ削除
```
sudo docker stop mynodered
sudo docker rm mynodered
```

### イメージ削除
コンテナが停止していない場合は失敗します。
```
sudo docker rmi node-red-hangouts
```
