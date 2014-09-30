# README #

本レポジトリの簡単な説明です。

### What is this repository for? ###

vagrant + degitalocean + ansible + varnish　で簡単にテスト環境を作るスクリプトサンプルです。
普通のhtml, wordpress , drupal ,mt のセットアップを8080 ポートで行い、varnish が 80 番ポートでLISTENします。
各CMSのインストールは、各VHにアクセスを行いインストールを実行してください。

### How do I get set up? ###

- #### vagrant -digital ocean 接続用レポジトリをclone

```
#!shell

$ git clone git@bitbucket.org:chienowa/vagrant-do.git
```

- #### 必要なプラグインをインストール

```
#!shell
cd vagrant-do
vagrant plugin install dotenv ;
vagrant plugin install vagrant-digitalocean ;
vagrant plugin list ;

```

- #### トークンをdigital ocean上で作成

vagrant からAPI経由で接続するためのトークンを生成してメモります。


- #### レポジトリ直下に .envを作成し、下記のような内容を記入

```
#!shell

# enable SSL communication with DigitalOcean
SSL_CERT_FILE=/usr/local/share/ca-bundle.crt
DO_SSH_USERNAME="ec2-user"
DO_SSH_KEY=${HOME}/.ssh/id_rsa
DO_CLIENT_ID="vagrant-do"
DO_API_TOKEN=“{changeme}"
```

- ####  起動したいレシピをチェックアウト

```
#!shell

$ git checkout master

$ ssh-add   
$ ssh-agent #digitalocean 上でgit cloneを行うためにagentを起動しておく.結果的にこれは特に必要なし。
$ vagrant up --provider=digital_ocean --provision

```

- #### ローカルのhostsに追加

```
#!shell

128.199.150.xx   default-do	default-do
128.199.150.xx   mt-do	mt-do
128.199.150.xx   drupal-do	drupal-do
128.199.150.xx   wordpress-do	wordpress-do
128.199.150.xx   costpa.net    costpa.net

```

- #### サーバ構築完了！

```
#!shell

http://wordpress-do:8080/
http://mt-do:8080/
http://drupal-do:8080/ 

でダイレクトアクセスし、インストールを実行します。

varnish は80番ポートで動作しており、
http://wordpress-do
http://mt-do
http://drupal-do

で利用可能です。
varnish/vars/main.yml で追加でキャッシュするサイトを指定することができます。

```

### Configuration ###

必要な設定値はyamlファイルに変数として定義しました。
データベース名や、キャッシュするバックエンドサイトを指定する場合は、
provision/{wordpress,mt,drupal,varnish}/vars/main.yml 各ファイルを修正してください。


### Who do I talk to? ###

vagrant + digitalocean + ansible でのサーバ構築自動化に興味あるみなさま。

ご自身の責任の範囲で自由に改変して使っていただいてもかまいません。