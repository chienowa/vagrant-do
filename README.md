# README #

本レポジトリの簡単な説明です。

### What is this repository for? ###

vagrant + degitalocean + ansible + varnish　で簡単にテスト環境を作るスクリプトサンプルです。
普通のhtml, wordpress , drupal ,mt のセットアップを8080 ポートで行い、varnish が 80 番ポートでLISTENします。
各CMSのインストールは、http://wordpress-do:8080/ , http://mt-do:8080/ , http://drupal-do:8080/ 
といった形でアクセスを行いインストールを実行してください。

### How do I get set up? ###

* Summary of set up

1. vagrant -digital ocean 接続用レポジトリをclone

```
#!shell

$ git clone git@bitbucket.org:chienowa/vagrant-do.git
```

2. 必要なプラグインをインストール

```
#!shell
cd vagrant-do
vagrant plugin install dotenv ;
vagrant plugin install vagrant-digitalocean ;
vagrant plugin list ;

```

3. トークンをdigital ocean上で作成

vagrant からAPI経由で接続するためのトークンを生成してメモります。


4. レポジトリ直下に .envを作成し、下記のような内容を記入

```
#!shell

# enable SSL communication with DigitalOcean
SSL_CERT_FILE=/usr/local/share/ca-bundle.crt
DO_SSH_USERNAME="ec2-user"
DO_SSH_KEY=${HOME}/.ssh/id_rsa
DO_CLIENT_ID="vagrant-do"
DO_API_TOKEN=“{changeme}"
```


5. 起動したいレシピをチェックアウト

```
#!shell

$ git checkout master

$ ssh-add
$ ssh-agent #digitalocean 上でgit cloneを行うためにagentを起動しておく
$ vagrant up --provider=digital_ocean --provision

```

6. サーバ構築完了！

* Configuration

必要な設定値はyamlファイルに変数として定義しました。
データベース名や、キャッシュするバックエンドサイトを指定する場合は、
provision/{wordpress,mt,drupal,varnish}/vars/main.yml 各ファイルを修正してください。


### Who do I talk to? ###

vagrant + digitalocean + ansible でのサーバ構築自動化に興味あるみなさま。

ご自身の責任の範囲で自由に改変して使っていただいてもかまいません。

