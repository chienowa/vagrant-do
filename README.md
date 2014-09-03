# README #

This README would normally document whatever steps are necessary to get your application up and running.

### What is this repository for? ###

* Quick summary
* Version
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### How do I get set up? ###

* Summary of set up

1. 必要なプラグインをインストール

```
#!shell

vagrant plugin install dotenv ;
vagrant plugin install vagrant-digitalocean ;
vagrant plugin list ;

```

2. トークンをdo上で作成

3. vagrant -digital ocean 接続用レポジトリをclone

```
#!shell

$ git clone git@bitbucket.org:chienowa/vagrant-do.git
```


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

$ git checkout varnish

$ ssh-add
$ ssh-agent #digitalocean 上でgit cloneを行うためにagentを起動しておく
$ vagrant up --provider=digital_ocean --provision

```

6. サーバ構築完了！

* Configuration
必要な設定値はyamlファイルに変数として定義しました。
データベース名や、キャッシュするバックエンドサイトを指定する場合は、各ファイルを修正してください。


### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact