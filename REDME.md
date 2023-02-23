# AWS環境のECサイト基盤をTerraformで構築する

## 概要
AWS環境上に**高可用**かつ**スケーラブル**なECサイトのインフラ基盤をTerraformで構築するソースコードを作成しました。
**セキュリティ面**にも配慮し、AWS WAFの利用、CloudFrontオリジンへのアクセス制限、DB認証情報のSecretsManager管理、セッションマネージャーを利用したEC2への接続といった構成をとりました。

## 構成について
- `ALB`、`EC2`、`RDS`から成るWeb3層アーキテクチャをマルチAZに配置
- インターネットからのアクセスは`CloudFront`経由として`AWS WAF`のマネージドルールを適用
- `ビューワー ~ CloudFront ~ オリジン`の間はHTTPSアクセスとし、CloudFront・ALBの証明書を`ACM`で作成
- CloudFrontのオリジンは、`S3（静的コンテンツ）`と`ALB（動的コンテンツ）`とし、オリジンへの直接アクセスは禁止
- `EC2`はターゲット追跡スケーリングポリシーを設定した`AutoScaling Group`で構成し、`ALB`でリクエストを分散させる
- `AutoScaling Group`は「管理アプリ」用と「コンテンツアプリ」用の２系統から成り、ALBの`パスベースルーティング`で振り分けを行う
- EC2をAutoScaling構成とする関係で、セッション管理のために`ElastiCache for Redis`を想定（マルチAZ構成）
- RDSは`Aurora Serverless v2`を使い、垂直・水平スケーリングを有効化
- DBの認証情報は予め作成済みの`SystemsManager`シークレットを利用し、`EC2`で認証情報を保持しないようにする
- `VPC`内の`EC2`へのSSH接続は禁止とし、代わりにVPCエンドポイント経由でセッションマネージャーによる接続を可能とする
 
## 構成図
![diagram](diagram.drawio.svg)

## ソースコードについて
- `environments/`  
  環境ごとの設定ファイルをディレクト分けして配置
	- `{環境名}/provider.tf` ~ AWS等のプロバイダ情報を設定
	- `{環境名}/backend.tf` ~ tfstateファイルの保管先を設定
	- `{環境名}/main.tf` ~ 構築に試用するモジュールとパラメータなどを設定
- `modules/`  
  各モジュールをディレクトリ分けして配置（上記の`environments/{環境名}/main.tf`から参照）

## 構築手順
1. `environments/`配下に環境名のディレクトリを作成
   ```
	 mkdir environments/{環境名}
	 ```
2. `environments/{環境名}/`配下に設定ファイルを作成
3. Terraformの初期化（上記までで作成した環境ディレクトリでコマンドを実行）
   ```
	 cd environment/{環境名}/
	 terraform init
	 ```
4. ドライランを実行して、構築内容を確認
   ```
	 terraform plan
	 ```
5. ソースコード適用（リソース構築）
   ```
	 terraform apply

	 # 自動承認(実行ユーザーへの確認なしで適用する場合)
	 # terraform apply --auto-approve
	```