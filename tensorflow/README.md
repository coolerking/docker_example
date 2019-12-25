TensorFlow 開発環境
=================================

本リポジトリは、Docker実行環境上にTensorFlow開発環境コンテナを構築することができる。

# 前提

- Ubuntu Server 16.04 LTS
 - CentOS 7.x も可能だが要```env.sh```修正
- Docker Engineがインストール済みであること
- dockerコマンド実行可能ユーザ
- git コマンドがインストール済みであること

## GPU

GPU搭載サーバの場合は、NVIDIAドライバが導入済みであればOK（CUDA関連はコンテナ内にインストールされている）。

```nvidia-docker``` コマンドは要インストール

# 導入手順

- Dockerコマンド利用可能ユーザのホームディレクトリ上に本リポジトリを展開
- ```git``` コマンドでホームディレクトリ直下に ```tensorflow``` ディレクトリを配置
- ～.sh というファイル名すべてに、実行権限を付加( ```cd $HOME && chmod a+x -R ./*/*.sh```)


# 初回起動

'''$HOME/tensorflow/gpu/env.sh``` および ```$HOME/tensorflow/cpu/env.sh``` を確認して、必要であれば修正する。

必須で修正するもの:
- SYSLOG_HOST : ホスト側のIPアドレスにすること。ループバックは設定禁止（コンテナ側をさしてしまうので）。

環境変数で設定変更できるもの:
- TF_VER　: TensorFlowバージョン、下げることも可能（Docker Hub側にイメージがあれば）。
- PY_VER : Python 3.x か 2.x かのどちらか。2.xの場合は何も指定しない。
- BASE_DIR : これらのスクリプトの展開先パスが ${HOME}/tensorflow ではない場合変更する。


## GPU

```cd $HOME/tensorflow/gpu
./init.sh```

## CPU

```cd $HOME/tensorflow/cpu
./init.sh```

# Jupyter notebook

## GPU

http://＜インストール先サーバ＞:8888/ を開く。
パスワードは ```admin123``` 。

Terminalにて以下のコマンドを実行する。
```cd /notebook/share/init
chmod a+x init.sh
./init.sh```

## CPU

http://＜インストール先サーバ＞:8881/ を開く。
パスワードは ```admin123``` 。

Terminalにて以下のコマンドを実行する。
```cd /notebook/share/init
chmod a+x init.sh
./init.sh```

## ```/notebooks/share``` と ```/notebooks/work```

- ```/notebooks/share``` と ```/notebooks/work``` はホスト側のファイルシステムを参照しています
 - ```/notebooks/share``` はホスト側の ```$HOME/tensorflow/share``` 、 ```/notebooks/work``` はホスト側の ```$HOME/tensorflow/[cg]pu/work``` にそれぞれ連結
 - ```/share``` はCPU/GPU両方のコンテナで参照可能
 - ```/work``` は各コンテナで独立
- データおよびコードはこの２つのディレクトリに格納し、バックアップは　＄HOME/tensorflow を取得する運用を推奨

# 2回め以降の起動

操作を謝らないように、実行ディレクトリを分けている。

## GPU

```cd $HOME/tensorflow/gpu
./start.sh```

## CPU

```cd $HOME/tensorflow/cpu
./start.sh```

# 停止

## GPU

```cd $HOME/tensorflow/gpu
./stop.sh```

## CPU

```cd $HOME/tensorflow/cpu
./stop.sh```


# 停止およびコンテナ削除

コンテナを削除すると、再起動時 ```/notebooks/share``` と ```/notebooks/work``` 以外はファイルが復元されない。

```apt``` コマンドや ```pip``` コマンドでインストールしたパッケージも初期化される。逆にインストールに失敗した場合は、コンテナを削除すれば良い（ソースコードは要退避）。

## GPU

```cd $HOME/tensorflow/gpu
./drop.sh```

## CPU

```cd $HOME/tensorflow/cpu
./drop.sh```

# コンテナ起動状況確認

```docker ps``` にて確認可能。

# 注意事項

- サーバを停止した場合、コンテナは自動で起動されない
 - ```start.sh``` を手動で実行すること
 -　自動実行したい場合は、 ```docker-compose``` を使用する(GPU環境は自動起動不可)
- 運用では ```work``` や ```share``` 内でのみ開発を行うことを推奨
 - バックアップはホスト側の ```$HOME/tensorflw``` を ```rsync``` などでコピーすることを推奨
- GPU環境で実行可能なジョブは同時１個のみ
 - 2個目はエラーとなる
 - GPU側、CPU側の利用は可能
 - CPU側では複数起動可能だが、おそらく主メモリ不足で止まる
- デフォルトはTensorFlow 1.3 / Python3.x
 - python2 にしたい場合は、env.shを編集し、再度コンテナを作り直すこと
 - TensorFlowバージョン変更したい場合も、再度コンテナを作り直す必要あり
- ```pid``` ディレクトリ内は基本手で削除してはならない
 - スクリプトが使用するため
- コンテナ停止を ```docker``` コマンドで実行してはならない
 - ```pid``` ディレクトリ内のコンテナIDと整合性が合わなくなるので
 - 実行した場合は、pid内のすべてのファイルを消し、再度 ```init.sh``` でコンテナを作り直すこと
 - コンテナを作り直した場合は再度 ```/notebooks/share/init/init.sh``` も実行すること
- Docker Compose を使う場合は、GPUを利用するコンテナを起動できない
 - docker-compose コマンドでは ```nvidia-docker``` を使用できないため
