pipeline {

    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        booleanParam(name: 'destroyInfra', defaultValue: false, description: 'Destroy infrastructure after apply?')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {

        stage('Checkout') {
            steps {
                dir('terraform') {
                    git branch: 'main', url: 'https://github.com/Urmilaa/Terraform-Jenkins1.git'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                    sh 'terraform show -no-color tfplan > tfplan.txt'
                }
            }
        }

        stage('Approval') {

            when {
                not { equals expected: true, actual: params.autoApprove }
            }

            steps {
                script {
                    def plan = readFile 'terraform/tfplan.txt'

                    input message: "Do you want to apply the plan?",
                    parameters: [
                        text(name: 'Terraform Plan', defaultValue: plan, description: 'Review Terraform Plan')
                    ]
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }
         stage('Destroy Approval') {

            when {
                equals expected: true, actual: params.destroyInfra
            }

            steps {
                input message: "Are you sure you want to destroy the infrastructure?"
            }
        }

        stage('Terraform Destroy') {

            when {
                equals expected: true, actual: params.destroyInfra
            }

            steps {
                dir('terraform') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }
}
