WebPot Collaboration Tower3サーバ構築手順
=========================

# 概要

## WebPot

WebPot とは、TI部にて規定したWebフレームワーク標準の総称です。

## WebPot Collaboration

WebPot には様々な種類があります。たとえば、WebPot Core は、推奨するOSSライブラリ群であり、現在はgradleファイルとして提供されています。WebPot SI は、ドキュメントサンプルおよび簡単な書き方の標準のDocksとサンプルコードAppsで構成されています。WebPot Testing は、OSSテストフレームワークライブラリ群です。

WebPot Collaboration は、プロジェクト推敲中にメンバ内で使用するサーバ類のOSS群です。

## WebPot Collaboration Tower3

WebPot Collaboration は、現在Tower1からTower3まであり、それぞれ選択されたOSS数が異なります。

Tower3は、Redmine、Subversion、Jenkins、メールサーバ、チャットサーバすべてを１つのLDAPサーバで管理する単一サーバを指します。


本文書は、このTower3サーバを個別にセットアップできるように手順化したものです。

# 導入手順

## 前提

以下のサーバ環境が用意できていることとします。

- 30GB 以上のHDD
- 8GB 以上のメモリ
- 2 vCPU 以上のコンピュータリソース
- CentOS 7 最新版が最小構成で導入済み
- 社内LANに接続(proxyあり前提)
 - 固定IPとする

また上記サーバへSSHアクセス可能なターミナル接続ソフトウェアも導入済みとします。

# 初期設定

ターミナル接続ソフトでログインし、root権限のユーザにスイッチする。

```
sudo su -```

## IPv6無効化

```
vi /etc/default/grub
```

```js:/etc/default/grub
# 6行目：変更
GRUB_CMDLINE_LINUX="ipv6.disable=1 rd.lvm.lv=fedora-server/root..... ```

```
grub2-mkconfig -o /boot/grub2/grub.cfg
ip addr show
※IPアドレスメモ```

## PROXY設定

```
vi /etc/yum.conf```

```js:/etc/yum.conf
## webpot
proxy=http://solidproxy.exa-corp.co.jp:8080```

```
vi /root/.bashrc```

```js:/root/.bashrc
# 最終行に追加
## webpot
export HTTP_PROXY=http://solidproxy.exa-corp.co.jp:8080
export HTTPS_PROXY=http://solidproxy.exa-corp.co.jp:8080
export NO_PROXY=localhost,127.0.0.1,*.exa-corp.co.jp,*.webpot.local,192.168.*,10.*,172.*,160.14.*
export http_proxy=$HTTP_PROXY
export https_proxy=$HTTPS_PROXY
export no_proxy=$NO_PROXY
export LANG=C```

```
vi /root/.curlrc```

```js:.curlrc
# 新規作成
proxy="http://solidproxy.exa-corp.co.jp:8080"```

```
reboot```

## パッケージ最新化

```
yum -y update```

## ftp/時刻同期

```
yum -y install ntpdate vsftpd
ntpdate 160.14.254.1```

```
vi /etc/vsftpd/vsftpd.conf```

```js:/etc/vsftpd/vsftpd.conf
# 12行目：匿名ログイン禁止
anonymous_enable=NO

# 82,83行目：コメント解除 ( アスキーモードでの転送を許可 )
ascii_upload_enable=YES
ascii_download_enable=YES

# 100,101行目：コメント解除 ( chroot有効 )
chroot_local_user=YES
chroot_list_enable=YES

# 103行目：コメント解除 ( chroot リストファイル指定 )
chroot_list_file=/etc/vsftpd/chroot_list

# 109行目：コメント解除 ( ディレクトリごと一括での転送有効 )
ls_recurse_enable=YES

# 114行目：変更 ( IPv4をリスンする )
listen=YES

# 123行目：変更 ( もし不要なら IPv6 はリスンしない )
listen_ipv6=NO

# 最終行へ追記
## webpot
use_localtime=YES
seccomp_sandbox=NO'''

'''
systemctl disable ntpdate
systemctl start vsftpd
systemctl enable vsftpd
vi /etc/vsftpd/chroot_list'''

'''js:/etc/vsftpd/chroot_list
※以下の内容で新規作成
admin```

```
setsebool -P ftpd_full_access on
firewall-cmd --add-service=ftp --permanent
firewall-cmd --relad```


# FreeIPA導入

```
vi /etc/hosts```

```js:/etc/hosts
# 最終行に追加
<新IPアドレス> tower3.webpot.local tower3```

```
yum -y install ipa-server ipa-server-dns bind bind-dyndb-ldap

ipa-server-install --setup-dns --mkhomedir
Enter(tower3.webpot.local)
Enter(webpot.local)
Enter(WEBPOT.LOCAL)
admin123 (Directory Manager)
admin123 (confirm)
admin123 (IPA admin)
admin123 (confirm)
yes (configure DNS forwarders)
yes (DNS config to forwarders?)
Enter (additional forwarder ip)
no (search for missing reverse zones)
yes (these setting ok?)
※時間がかかる

firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --zone=public --add-service=freeipa-ldap --permanent
firewall-cmd --zone=public --add-service=ldap --permanent
firewall-cmd --zone=public --add-service=freeipa-ldaps --permanent
firewall-cmd --zone=public --add-service=ldaps --permanent
firewall-cmd --zone=public --add-service=dns --permanent
firewall-cmd --zone=public --add-service=kerberos --permanent
firewall-cmd --zone=public --add-service=kpasswd --permanent
firewall-cmd --zone=public --add-service=imaps --permanent
firewall-cmd --zone=public --add-service=ntp --permanent
firewall-cmd --reload

kinit admin
admin123

klist
ipa config-mod --defaultshell=/bin/bash
authconfig --enablemkhomedir --update
su - admin
exit

ipa user-add wpadmin --first=Administrator --last=WebPot --homedir=/home/wpadmin --password
admin123
admin123
ipa user-add tsukamoto --first=Akito --last=Tsukamoto --homedir=/home/tsukamoto --password
tsukamoto
tsukamoto

su - wpadmin
exit
su - tsukamoto
exit

vi /etc/named.conf```

```js:/etc/named.conf
# 17行目を変更
dnssec-enable no;```

```
ipactl restart```

メモ帳を管理者として実行
C:\Windows\system32\drivers\etc\hostsを開く
※160.14.95.121 tower3.webpot.localを追加

```js:C:\Windows\system32\drivers\etc\hosts
160.14.95.121 tower3.webpot.local tower3```

Chromeを起動、http://tower3.webpot.local を開く
詳細設定
tower3.webpot.local にアクセスする（安全ではありません）
認証が必要ダイアログ→Xで抜ける
admin
admin123
Login
wpadmin を選択
User Groupを選択
+Add
adminis, trust admins をチェック
＞
Add
Network Servicesタグ
DNS＞DNS Global Configuration
Global forwarders>Add
160.14.23.11
Global forwarders>Add
160.14.95.11
Global forwarders>Add
160.14.254.1
Save
※ワーニングが出るがそのままにする
ログアウト

wpadmin
admin123
空欄
admin123
admin123
Reset Password and Login
ログアウト

tsukamoto
tsukamoto
空欄
tsukamoto
tsukamoto
Reset Password and Login
ログアウト

```
nmcli con mod ens3 ipv4.dns "127.0.0.1"
reboot```

rootでログインし直す。

```
cat /etc/resolv.conf
※nameserverが127.0.0.1のみになっていることを確認
ping solidproxy.exa-corp.co.jp
dig solidproxy.exa-corp.co.jp
nslookup solidproxy.exa-corp.co.jp
※正常にproxyが引けていることを確認```

## ClamAV導入

```
yum -y install yum-plugin-priorities
sed -i -e "s/\]$/\]\npriority=1/g" /etc/yum.repos.d/CentOS-Base.repo
yum -y install epel-release
sed -i -e "s/\]$/\]\npriority=5/g" /etc/yum.repos.d/epel.repo
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/epel.repo
yum -y install centos-release-scl-rh centos-release-scl
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/remi-safe.repo
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/remi-safe.repo

yum --enablerepo=epel -y install clamav clamav-update

vi /etc/freshclam.conf```

```js:/etc/freshclam.conf
# Comment or remove the line below.
#Example
（略）

# Proxy settings
# Default: disabled
HTTPProxyServer solidproxy.exa-corp.co.jp
HTTPProxyPort 8080
#HTTPProxyUsername myusername
#HTTPProxyPassword mypass```

```
mkdir /opt/clamav
chmod -R a+rwx /opt
vi /etc/cron.daily/clamav```

``shell:/etc/cron.daily/clamav
#!/bin/sh
/usr/bin/freshclam --log /var/log/freshclam.log 1> /dev/null 2>&1
/usr/bin/clamscan --infected --move /opt/clamav --recursive /  --exclude-dir="^/proc|^/sys|^/dev|^/mnt|^/opt/clamav" 1>/dev/null 2>&1```

```
chmod u+x,g+x /etc/cron.daily/clamav
vi /etc/sysconfig/freshclam```

```shell:/etc/sysconfig/freshclam
#FRESHCLAM_DELAY=disabled-warn  # REMOVE ME```

## Subversion

```
yum -y install subversion subversion-tools httpd mod_dav_svn ftp mod_ldap git
vi /etc/httpd/conf.modules.d/10-subversion.conf```

```shell:/etc/httpd/conf.modules.d/10-subversion.conf
#最終行に追加
## webpot
Alias	/svn      		/var/www/svn
<Location /svn>
        DAV                     svn
        SVNParentPath           /var/www/svn
        AuthType        Basic
        AuthName        "WebPot Collaboration LDAP"
        AuthBasicProvider       ldap
        AuthLDAPURL     ldap://tower3.webpot.local/cn=users,cn=compat,dc=webpot,dc=local?uid?sub?(objectClass=*)
        Require         ldap-filter objectClass=posixAccount
</Location>```

```
mkdir /var/www/svn
cd /var/www/svn
svnadmin create repo
cd ..
chown -R apache:apache ./svn
chmod -R a+rw ./svn
chcon -R -t httpd_sys_content_t /var/www/svn
chcon -R -t httpd_sys_rw_content_t /var/www/svn
firewall-cmd --reload
systemctl restart httpd.service

cd /tmp
mkdir default
cd default
mkdir trunk
mkdir branches
mkdir tags
svn import -m "WebPot Collaboration default project" /tmp/default file:///var/www/svn/repo/default
cd ..
rm -rf ./default```

ローカルPCでhttp://tower3.webpot.local/svn/repo/default をチェックアウト
wpadmin/admin123 を使う
trunk ディレクトリへ初期プロジェクト構成を投入

ターミナル上で
```
cd /var/www
chown -R apache:apache ./svn```

投入した全てのファイル、ディレクトリをaddしてコミット
tsukamoto/tsukamoto を使う


## Webメール

```
vi /etc/postfix/main.cf```

```shell:/etc/postfix/main.cf
# 75行目：コメント解除しホスト名指定
myhostname = tower3.webpot.local
# 83行目：コメント解除しドメイン名指定
mydomain = webpot.local
# 99行目：コメント解除
myorigin = $mydomain
# 113行目：コメント解除
inet_interfaces = all
# 116行目：コメント化
#inet_interfaces = localhost
# 164行目：コメント
#mydestination = $myhostname, localhost.$mydomain, localhost
#165行目：コメント除去
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
# 264行目：コメント解除し自ネットワーク追記
mynetworks = 127.0.0.0/8, 10.0.0.0/8, 160.14.0.0/16, 172.0.0.0/8
# 419行目：コメント解除しMaildir形式へ移行
home_mailbox = Maildir/
# 574行目：追記
smtpd_banner = $myhostname ESMTP
# 最終行へ追記
## webpot
# limits
message_size_limit = 10485760
mailbox_size_limit = 1073741824
# SMTP-Auth
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_sasl_security_options = noanonymous
smtpd_sasl_local_domain = $myhostname
smtpd_recipient_restrictions = permit_mynetworks,permit_auth_destination,permit_sasl_authenticated,reject```

```
yum -y install dovecot
vi /etc/dovecot/dovecot.conf```

```shell:/etc/dovecot/dovecot.conf
# 24行目：コメント解除
protocols = imap pop3 lmtp
# 31行目：記入
listen = *```

```
vi /etc/dovecot/conf.d/10-auth.conf```

```shell:/etc/dovecot/conf.d/10-auth.conf
# 10行目：コメント解除し変更(プレーンテキスト認証も許可する)
disable_plaintext_auth = no
# 100行目：追記
auth_mechanisms = plain login```

```
vi /etc/dovecot/conf.d/10-mail.conf```

```shell:/etc/dovecot/conf.d/10-mail.conf
# 24行目：コメント解除
mail_location = maildir:~/Maildir```

```
vi /etc/dovecot/conf.d/10-master.conf```

```shell:/etc/dovecot/conf.d/10-master.conf
#96-98行目：コメント解除し追記
# Postfix smtp-auth
unix_listener /var/spool/postfix/private/auth {
    mode = 0666
    user = postfix
    group = postfix
}```

```
vi /etc/dovecot/conf.d/10-ssl.conf```

```shell:/etc/dovecot/conf.d/10-ssl.conf
# 8行目：変更（SSLを要求しない)
ssl = no```

```
systemctl restart dovecot
systemctl enable dovecot

cd /etc/pki/tls/certs
make server.key```

```
admin123 (pass phrase)
admin123 (confirm)```

```
openssl rsa -in server.key -out server.key```
```
admin123 (pass phrase)```

```
make server.csr```

```
JP
Kanagawa
Kawasaki
exa corporation
Technology Innovation Dept.
tower3.webpot.local
wpadmin@webpot.local
(enter)
(enter)```

```
openssl x509 -in server.csr -out server.crt -req -signkey server.key -days 3650
cd
vi /etc/postfix/main.cf```

```shell:/etc/postfix/main.cf
# 最終行に追記
# tls
smtpd_use_tls = yes
smtpd_tls_cert_file = /etc/pki/tls/certs/server.crt
smtpd_tls_key_file = /etc/pki/tls/certs/server.key
smtpd_tls_session_cache_database = btree:/etc/postfix/smtpd_scache```

```
vi /etc/postfix/master.cf```

```shell:/etc/postfix/master.cf
# 26-28行目：コメント解除

smtps       inet   n       -       n       -       -       smtpd
  -o syslog_name=postfix/smtps
  -o smtpd_tls_wrappermode=yes```

```
vi /etc/dovecot/conf.d/10-ssl.conf```

```shell:/etc/dovecot/conf.d/10-ssl.conf
# 8行目：変更
ssl = yes
# 14,15行目：証明書/鍵ファイル指定
ssl_cert = </etc/pki/tls/certs/server.crt
ssl_key = </etc/pki/tls/certs/server.key```

```
systemctl restart postfix
systemctl restart dovecot

yum --enablerepo=epel -y install amavisd-new clamav-server clamav-server-systemd
cp /usr/share/doc/clamav-server*/clamd.sysconfig /etc/sysconfig/clamd.amavisd

vi /etc/sysconfig/clamd.amavisd```

```shell:/etc/sysconfig/clamd.amavisd
# 1, 2行目：コメント解除し変更
CLAMD_CONFIGFILE=/etc/clamd.d/amavisd.conf
CLAMD_SOCKET=/var/run/clamd.amavisd/clamd.sock```

```
vi /etc/tmpfiles.d/clamd.amavisd.conf```

```shell:/etc/tmpfiles.d/clamd.amavisd.conf
# 新規作成
d /var/run/clamd.amavisd 0755 amavis amavis -```

```
vi /usr/lib/systemd/system/clamd@.service```

```shell:/usr/lib/systemd/system/clamd@.service
# 最終行に追記
[Install]
WantedBy=multi-user.target```

```
systemctl start clamd@amavisd
systemctl enable clamd@amavisd

vi /etc/amavisd/amavisd.conf```

```
# 20行目：自ドメイン名に変更
$mydomain = 'webpot.local';
# 152行目：自ホスト名に変更
$myhostname = 'tower3.webpot.local';
# 154,155行目：コメント解除
$notify_method = 'smtp:[127.0.0.1]:10025';
$forward_method = 'smtp:[127.0.0.1]:10025';```

```
systemctl start amavisd
systemctl enable amavisd
systemctl start spamassassin
systemctl enable spamassassin

vi /etc/postfix/main.cf```

```shell:/etc/postfix/main.cf
# 最終行に追記
# amavisd
content_filter=smtp-amavis:[127.0.0.1]:10024```

```
vi /etc/postfix/master.cf```

```shell:/etc/postfix/master.cf
# 最終行に追記
## webpot
smtp-amavis unix -    -    n    -    2 smtp
    -o smtp_data_done_timeout=1200
    -o smtp_send_xforward_command=yes
    -o disable_dns_lookups=yes
127.0.0.1:10025 inet n    -    n    -    - smtpd
    -o content_filter=
    -o local_recipient_maps=
    -o relay_recipient_maps=
    -o smtpd_restriction_classes=
    -o smtpd_client_restrictions=
    -o smtpd_helo_restrictions=
    -o smtpd_sender_restrictions=
    -o smtpd_recipient_restrictions=permit_mynetworks,reject
    -o mynetworks=127.0.0.0/8
    -o strict_rfc821_envelopes=yes
    -o smtpd_error_sleep_time=0
    -o smtpd_soft_error_limit=1001
    -o smtpd_hard_error_limit=1000```

```
systemctl restart postfix

kinit admin```

```
admin123```

```
ipa dnsrecord-add webpot.local @ --mx-preference=0 --mx-exchanger=tower3.webpot.local.```

```
yum -y install php php-mbstring php-pear

vi /etc/php.ini```

```shell:/etc/php.ini
# 878行目：コメント解除し自身のタイムゾーンを追記
date.timezone = "Asia/Tokyo"```

```
systemctl restart httpd
yum -y install mariadb-server php-mysqlnd
vi /etc/my.cnf```

```shell:/etc/my.cnf
#10行目に記述
character-set-server=utf8```

```
systemctl start mariadb
systemctl enable mariadb

mysql_secure_installation```

```
(Enter)
(Enter)
admin123 (mariadb root)
admin123 (confirm)
(Enter)
(Enter)
(Enter)
(Enter)```

```
yum --enablerepo=epel -y install roundcubemail

mysql -uroot -padmin123```

```
create database roundcube;
grant all privileges on roundcube.* to roundcube@'localhost' identified by 'admin123';
flush privileges;
exit```

```
cd /usr/share/roundcubemail/SQL
mysql -u roundcube -p roundcube < mysql.initial.sql```

```
admin123```

```
cd

cp -p /etc/roundcubemail/defaults.inc.php /etc/roundcubemail/config.inc.php
vi /etc/roundcubemail/config.inc.php```

```php:/etc/roundcubemail/config.inc.php
# 27行目：以下のように変更 ('password'の箇所はroundcubeに設定したパスワード)
$config['db_dsnw'] = 'mysql://roundcube:admin123@localhost/roundcube';

# 73行目：ログの日付形式を「年-月-日 時:分:秒」に変更
$config['log_date_format'] = 'Y-M-d H:i:s O';

# 232行目：SMTPサーバーを指定
$config['smtp_server'] = 'localhost';

# 240行目：変更 ( SMTP認証にIMAP認証と同じユーザー名を使う )
$config['smtp_user'] = '%u';

# 244行目：変更 ( SMTP認証にIMAP認証と同じパスワードを使う )
$config['smtp_pass'] = '%p';

# 248行目：変更 ( SMTP認証タイプ )
$config['smtp_auth_type'] = 'LOGIN';

# 449行目：ドメインを指定
$config['mail_domain'] = 'webpot.local';

# 467行目：表示画面のタイトルを変更
$config['product_name'] = 'WebPot Collaboration mail';

# 470行目：UserAgent変更
$config['useragent'] = 'WebPot Collaboration mail';

# 602行目：日本語に変更
$config['language'] = ja_JP;

# 953行目：デフォルト文字セット変更
$config['default_charset'] = 'iso-2022-jp';```

```
vi /etc/httpd/conf.d/roundcubemail.conf```

```shell:/etc/httpd/conf.d/roundcubemail.conf
# 14行目：以下の行を挿入
Require ip 160.14.0.0/16```

```
cd
vi .forward```

```shell:~/.forward
wpadmin```

```
firewall-cmd --zone=public --add-service=smtp --permanent
firewall-cmd --zone=public --add-service=pop3s --permanent
firewall-cmd --reload
systemctl restart httpd```


ブラウザからhttp://tower3.webpot.local/roundcubemail/を開く

wpadmin/admin123 でログイン
設定（右上）
フォルダー
＋
trash 保存
＋
sent 保存
＋
spam 保存
＋
temp 保存
設定（左）
特殊なフォルダー
temp sent spam trash 保存
ログアウト
admin/admin123 でログイン
設定（右上）
フォルダー
＋
trash 保存
＋
sent 保存
＋
spam 保存
＋
temp 保存
設定（左）
特殊なフォルダー
temp sent spam trash 保存
tsukamoto/tsukamoto でログイン
設定（右上）
フォルダー
＋
trash 保存
＋
sent 保存
＋
spam 保存
＋
temp 保存
設定（左）
特殊なフォルダー
temp sent spam trash 保存


## docker

```
yum -y install yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum makecache fast
yum -y install docker-ce
mkdir -p /etc/systemd/system/docker.service.d
vi /etc/systemd/system/docker.service.d/http-proxy.conf```

```shell:/etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://solidproxy.exa-corp.co.jp:8080/" "HTTPS_PROXY=http://solidproxy.exa-corp.co.jp:8080/" "NO_PROXY=localhost,127.0.0.1,*.webpot.local,*.exa-corp.co.jp,160.14.*,10.*,192.168.*"```

```
systemctl start docker
systemctl enable docker```

※docker-composeはバージョンアップされている可能性があるので、サイトでインストール方法をチェックすること

```
curl -L --fail https://github.com/docker/compose/releases/download/1.13.0/run.sh > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
cd /opt
mkdir /opt/docker
cd docker
mkdir data
mkdir data/redmine
mkdir data/mariadb
mkdir data/mariadb/data
mkdir data/mariadb/conf
mkdir data/jenkins
mkdir data/rocketchat
mkdir data/mongo
mkdir data/mongo/db
mkdir data/mongo/dump
chmod -R a+rwx data
chcon -Rt svirt_sandbox_file_t /opt/docker/data
chcon -Rt svirt_sandbox_file_t /opt/docker/data/jenkins
chcon -Rt svirt_sandbox_file_t /opt/docker/data/redmine
chcon -Rt svirt_sandbox_file_t /opt/docker/data/mariadb/conf
chcon -Rt svirt_sandbox_file_t /opt/docker/data/mariadb/data
chcon -Rt svirt_sandbox_file_t /opt/docker/data/mongo/db
chcon -Rt svirt_sandbox_file_t /opt/docker/data/mongo/dump
chcon -Rt svirt_sandbox_file_t /opt/docker/data/rocketchat
firewall-cmd --zone=public --add-port=3000/tcp --permanent
firewall-cmd --zone=public --add-port=3001/tcp --permanent
firewall-cmd --zone=public --add-port=3002/tcp --permanent
firewall-cmd --reload
cp /etc/my.cnf.d/server.cnf /opt/docker/data/mariadb/conf/
vi /opt/docker/data/mariadb/conf/server.cnf```

```shell:/opt/docker/data/mariadb/conf/server.cnf
# 13行目：以下記述
character-set-server=utf8```

```
vi /opt/docker/docker-compose.yml```
※以下の内容で新規作成

```/opt/docker/docker-compose.yml
version: '2'

services:

  jenkins:
    image: jenkins:latest
    restart: unless-stopped
    volumes:
      - ./data/jenkins:/var/jenkins_home
    ports:
      - 3002:8080
      - 50000:50000
    environment:
      - TZ=Asia/Tokyo
      - HTTP_PROXY=http://solidproxy.exa-corp.co.jp:8080
      - HTTPS_PROXY=http://solidproxy.exa-corp.co.jp:8080

  redmine:
    image: redmine:latest
    restart: unless-stopped
    volumes:
      - ./data/redmine:/usr/src/redmine/files
    ports:
      - 3001:3000
    environment:
      - REDMINE_DB_MYSQL=mariadb
      - REDMINE_DB_PASSWORD=admin123
      - TZ=Asia/Tokyo
      - HTTP_PROXY=http://solidproxy.exa-corp.co.jp:8080
      - HTTPS_PROXY=http://solidproxy.exa-corp.co.jp:8080
    depends_on:
      - mariadb

  mariadb:
    image: mariadb:latest
    restart: unless-stopped
    volumes:
      - ./data/mariadb/conf:/etc/mysql/conf.d
      - ./data/mariadb/data:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=admin123
      - MYSQL_DATABASE=redmine
      - TZ=Asia/Tokyo

  rocketchat:
    image: rocketchat/rocket.chat:latest
    restart: unless-stopped
    volumes:
      - ./data/rocketchat:/app/uploads
    ports:
      - 3000:3000
    environment:
      - PORT=3000
      - ROOT_URL=http://tower3.webpot.local:3000
      - MONGO_URL=mongodb://mongo:27017/rocketchat
      - MONGO_OPLOG_URL=mongodb://mongo:27017/local
      - MAIL_URL=smtp://127.0.0.11
      - TZ=Asia/Tokyo
    depends_on:
      - mongo
    labels:
      - "traefik.backend=rocketchat"
      - "traefik.frontend.rule=Host: webpot.local"

  mongo:
    image: mongo:3.2
    restart: unless-stopped
    volumes:
     - ./data/mongo/db:/data/db
     - ./data/mongo/dump:/dump
    command: mongod --smallfiles --oplogSize 128 --replSet rs0
    labels:
      - "traefik.enable=false"

  mongo-init-replica:
    image: mongo:3.2
    command: 'mongo mongo/rocketchat --eval "rs.initiate({ _id: ''rs0'', members: [ { _id: 0, host: ''localhost:27017'' } ]})"'
    depends_on:
      - mongo```

```
docker-compose up -d
docker-compose ps```

ブラウザで　http://tower3.webpot.local:3000 を開く

新しいアカウントを登録

admin
admin@webpot.local
admin123
admin123
新しいアカウントを登録
ユーザー名を使う
admin>マイアカウント>アバター
ファイルを選択
アップロードしたアバターを使用
マイアカウント
admin
管理
LDAP
有効にする： はい
ホスト: 172.17.0.1
ドメインベース: cn=users,cn=accounts,dc=webpot,dc=local
ドメイン検索ユーザー: uid=admin,cn=users,cn=accounts,dc=webpot,dc=local
ドメイン検索のパスワード: admin123
ドメイン検索ユーザーID: uid
ドメイン検索の objectclass: 空欄
ドメイン検索の objectCategory: 空欄
ユーザー名フィールド: #{givenName}.#{sn}
データを同期する: はい
変更を保存
接続をテスト ..少しかかる
ユーザーを同期
管理
admin
ログアウト
wpadmin
admin123
ログイン
Administrator WebPot>マイアカウント>アバター
ファイルを選択
アップロードしたアバターを使用
マイアカウント
Administrator WebPot>ログアウト
admin@webpot
admin123
admin>管理>ユーザー
Administrator WebPot
管理者に設定
管理
admin>ログアウト
tsukamoto
tsukamoto
ログイン
Akito Tsukamoto>マイアカウント>アバター
ファイルを選択
アップロードしたアバターを使用
マイアカウント
Akito Tsukamoto>ログアウト


ブラウザで http://tower3.webpot.local:3001 で開く
admin/adminでログイン
パスワードをadmin123に変更
メールアドレス: admin@webpot.local
言語: Japanese(日本語)
通知しない
タイムゾーン: (GMT+09:00) Tokyo
保存
画面左上の管理
デフォルト設定をロード
LDAP認証
名称：WebPot
ホスト：localhost
ポート: 636
LDAPS: チェック
アカウント: 空欄
パスワード: 空欄
検索範囲: cn=users,cn=accounts,dc=webpot,dc=local
LDAPフィルタ: 空欄
タイムアウト(秒単位): 空欄
合わせてユーザを作成: チェック
属性
ログイン属性: uid
名前属性: givenname
名字属性: sn
メール属性: mail
テスト→接続しました
ログアウト
ログイン
wpadmin/admin123
メールアドレス: wpadmin@webpot.local
言語: Japanese(日本語)
送信
通知しない
タイムゾーン: (GMT+09:00) Tokyo
保存
ログアウト
ログイン
tsukamoto/tsukamoto
メールアドレス: tsukamoto@webpot.local
言語: Japanese(日本語)
送信
通知しない
タイムゾーン: (GMT+09:00) Tokyo
保存
ログアウト
ログイン
admin/admin123
管理
ユーザー
wpadmin
システム管理者: チェック
保存
プロジェクト
新しいプロジェクト
※以降、初期設定ガイドp15～pを実施
ログアウト

ブラウザで http://tower3.webpot.local:3002 を開く

```
cd /opt/docker
docker-compose logs jenkins

cat /var/lib/jenkins/secrets/initialAdminPassword
※結果をコピペして、ブラウザのパスワード欄に貼り付け```

Continue
Configre Proxy
サーバー： 160.14.237.66
ポート番号: 8080
対象外ホスト:
127.0.0.1
localhost
*.webpot.local
*.exa-corp.co.jp
160.14.*
192.168.*
172.17.*
10.*

Save and Configure
Install suggested plugins
ユーザー名: admin
パスワード: admin123
パスワード確認: admin123
フルネーム: WebPot Administrator
メールアドレス: admin@webpot.local
Save and Finish
Start using Jenkins
Jenkinsの管理
グローバルセキュリティの設定
アクセス制御＞ユーザー情報＞LDAP
サーバー: 172.17.0.1
高度な設定
root DN: dc=webpot,dc=local
User search base: cn=users,cn=accounts
User search filter 「uid={0}」
保存
ログアウト
wpadmin/admin123 でログイン


以下のプラグインを手動ダウンロード
SLOCCount Plug-in
JaCoCo plugin
Deploy to container Plugin
Checkstyle Plug-in
FindBugs Plug-in
Task Scanner Plug-in
Job Configuration History Plugin
emotional-jenkins-plugin
Green Balls
Nested View Plugin
Xvfb plugin
Build Pipeline Plugin
RocketChat Nortifier
Metrics Disk Usage Plugin
Monitoring

## バックアップ

```
vi /etc/rsync_execlude.lst```

※以下の内容で新規作成
```shell:/etc/rsync_execlude.lst
test
old```

```
mkdir /opt/backup
vi /opt/webpot_backup.sh```

※以下の内容で、新規作成
```shell:/opt/webpot_backup.sh
#!/bin/bash
############################################################
# /opt/webpot_backup.sh
#
# Operations:
#  - FreeIPA backup(online)
#  - Switch offline
#    - Roundcubemail backup
#    - Subversion backup
#    - Docker Containers backup
#      - redmine + mariadb / jenkins / rocketchat + mongo
#  - Switch online
#  - Sweep old backup
#  - <YOU MUST SET> rsync to another node
#
############################################################
##
## customize area
##

# expire date
EXPIRE_DAYS=3

# rsync server settings
RSYNC_SERVER=rsync.server.fqdn
RSYNC_TARGET=tower3

# bin path (CentOS7)
RM=/usr/bin/rm
TAR=/usr/bin/tar
IPA_BACKUP=/usr/sbin/ipa-backup
DOCKER_COMPOSE=/usr/local/bin/docker-compose
IPACTL=/usr/sbin/ipactl
SYSTEMCTL=/usr/bin/systemctl
DATE=/usr/bin/date
FIND=/usr/bin/find
RSYNC=/usr/bin/rsync


##
## backup target path
##

# FreeIPA
IPA_BACKUP_BASE=/var/lib/ipa/backup
OPENLDAP_BASE=/etc/openldap

# Roundcube/mail
MARIADB_BASE=/var/lib/mysql
MAIL_SPOOL=/var/spool/mail
HOME_BASE=/home

# Subversion
SUB_BASE=/var/www/html/svn

# Docker Containers
DOCKER_BASE=/opt/docker

# backup file
BACKUP_BASE=/opt/backup
YYYYMMDDHHMMSS=`${DATE} +%Y%m%d%H%M%S`
SUFFIX=tar.gz



##
# Start operation
##



# FreeIPA backup(online)
cd /
${RM} -rf ${IPA_BACKUP_BASE}/ipa*
${IPA_BACKUP} --data --online
${TAR} cvfz ${BACKUP_BASE}/${YYYYMMDDHHMMSS}_freeipa.${SUFFIX} ${IPA_BACKUP_BASE} ${OPENLDAP_BASE} /etc/k* /etc/ipa



# Switch offline
${IPACTL} stop
${SYSTEMCTL} stop mariadb
${SYSTEMCTL} stop dovecot
cd ${DOCKER_BASE}
${DOCKER_COMPOSE} stop



# Roundcube/mail backup
cd /
${TAR} cvfz ${BACKUP_BASE}/${YYYYMMDDHHMMSS}_mail.${SUFFIX} ${MARIADB_BASE} ${HOME_BASE} ${MAIL_SPOOL}



# Subversion backup
cd /
${TAR} cvfz ${BACKUP_BASE}/${YYYYMMDDHHMMSS}_sub.${SUFFIX} ${SUB_BASE}



# Docker Containers backup
${TAR} cvfz ${BACKUP_BASE}/${YYYYMMDDHHMMSS}_dockers.${SUFFIX} ${DOCKER_BASE}



# Switch online
${IPACTL} start
${SYSTEMCTL} start mariadb
${SYSTEMCTL} start dovecot
cd ${DOCKER_BASE}
${DOCKER_COMPOSE} start



# Sweep old backup
${FIND} ${BACKUP_BASE} -name *.${SUFFIX} -mtime +${EXPIRE_DAYS} -exec ${RM} -f {} \;



# <YOU MUST SET> rsync to another node
#${RSYNC} -avz --delete --exclude-from=/etc/rsync_execlude.lst ${BACKUP_BASE}/ ${RDYNC_SERVER}:${RSYNC_TARGET}
echo "YOU NEED TO SETUP rsync SERVER and CONFIGURE /opt/webpot_backup.sh !"


##
# End of operation
##```

```
chmod +x /opt/webpot_backup.sh
crontab -e```

※以下の内容で新規作成
```
0 3 * * * /opt/webpot_backup.sh 1>/dev/null 2>&1```


## 参考：rsync server側設定例

rsyncサーバ（バックアップ先）のOSもCentOS7の場合、以下の手順で設定を行う。

```
yum -y install rsync
mkdir /opt/tower3_backup
systemctl start rsyncd
systemctl enable rsyncd
vi /etc/rsyncd.conf```

※以下の内容を最終行に追加
```shell:/etc/rsyncd.conf
[tower3]
path = /opt/tower3_backup
hosts allow = Tower3サーバのIPアドレス
hosts deny = *
list = true
uid = root
gid = root
read only = false```

# 本リポジトリについて

本リポジトリは、Docker ComposeによるRedmine、Jenkins、RocketChatの３つのサーバコンテナを起動する。
切り出して、使用することも可能。
