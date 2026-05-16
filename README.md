\# Cloud Resume Challenge - Backend (Visitor Counter API)



このリポジトリは、\[Cloud Resume Challenge](https://cloudresumechallenge.dev/) のバックエンドインフラおよび API ロジックを管理するためのものです。

Terraform を使用した \*\*Infrastructure as Code (IaC)\*\* と、GitHub Actions による \*\*CI/CD パイプライン\*\* を備えたサーバーレスアーキテクチャで構成されています。



\## 🏗️ Architecture



1\.  \*\*API Gateway\*\*: ブラウザからの HTTPS POST リクエストを受信。

2\.  \*\*AWS Lambda (Python)\*\*: DynamoDB の値をインクリメントし、現在の訪問者数を返却。

3\.  \*\*Amazon DynamoDB\*\*: 訪問者数をアトミックに保存・管理。

4\.  \*\*GitHub Actions\*\*: コードのプッシュをトリガーに、テスト・インフラ構築・デプロイを自動実行。



\---



\## 📂 Directory Structure



```text

cloud-resume-backend/

├── .github/workflows/

│   └── backend-ci.yml      # テスト実行 \& Terraform自動デプロイ

├── infra/                  # Terraform (IaC) 構成ファイル

│   ├── main.tf             # AWSプロバイダ、S3バックエンド(tfstate)定義

│   ├── variables.tf        # 変数定義 (region, env, project\_name)

│   ├── dynamodb.tf         # DynamoDBテーブル定義

│   ├── lambda.tf           # Lambda関数、IAMロール、権限定義

│   ├── api\_gateway.tf      # API Gateway (CORS設定含む)

│   └── outputs.tf          # APIエンドポイントの出力

├── lambda/                 # Lambdaソースコード

│   └── lambda\_function.py  # 訪問者数カウントロジック (Python)

├── tests/                  # 自動テスト関連

│   ├── test\_api.py         # APIスモークテスト

│   └── requirements.txt    # テスト用依存ライブラリ

└── README.md               # 本ファイル

```



\## 🛠️ Technology Stack

Cloud: AWS (ap-northeast-1)

IaC: Terraform v1.x

Language: Python 3.12

CI/CD: GitHub Actions (OIDC 認証)

Testing: Pytest / Requests



\## 🚀 Getting Started

1\. Prerequisites

Terraform の状態管理（tfstate）用 S3 バケットが AWS 上に作成されていること。

GitHub Actions 用の IAM ロール (OIDC) が作成され、適切な権限が付与されていること。

2\. GitHub Secrets の設定

リポジトリの Settings > Secrets and variables > Actions に以下のシークレットを登録してください。

Secret Name

Description

AWS\_IAM\_ROLE\_ARN

GitHub Actions が使用する IAM ロールの ARN

3\. Local Deployment (Manual)

ローカルから手動でデプロイする場合は以下を実行します。

Bash

cd infra

terraform init

terraform plan

terraform apply





\## 🔄 CI/CD Pipeline

main ブランチへのプッシュをトリガーに、以下のジョブが自動実行されます。

Checkout: ソースコードの取得。

Configure AWS Credentials: OIDC を使用して AWS への一時的なアクセス権を取得。

Zip Lambda: Python コードを zip 形式に圧縮。

Terraform Init \& Apply: インフラの変更差分を検出し、AWS 環境を最新化。

Smoke Test: デプロイされた API が正しく 200 OK を返し、カウントが増加するかを検証。



\## 🛡️ Security \& Best Practices

OIDC Authentication: 長期的な AWS アクセスキーを排除し、GitHub OIDC による一時的な認証情報を採用。

Minimal Privilege: Lambda の IAM ロールには、特定の DynamoDB テーブルへのアクセス権限のみを付与（最小権限の原則）。

CORS Configuration: ブラウザからのクロスオリジンリソース共有を適切に設定。



\## ✍️ Author

Ousuke Furuta

Infrastructure Engineer / AWS Certified Solutions Architect – Associate

\[GitHub Profile](https://github.com/ooooosuke)



