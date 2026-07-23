pipeline {

    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
       
    }

  
    stages {

        stage('Checkout') {
            steps {
                dir('terraform') {
                    git branch: 'main', url: 'https://github.com/pasytchangwa/Terraform-Jenkins1.git'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'   
                ]]) {
                    dir('terraform') {
                        sh 'aws sts get-caller-identity'
                        sh 'terraform init'
                    }
                }
            }
        }
          stage('Terraform Validate') {
            steps {
                dir('terraform') {
                sh 'terraform validate'
                }
            }
        }
        stage('Terraform Plan') {
            steps {                                
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir('terraform') {
                        sh 'terraform plan -out=tfplan'
                        sh 'terraform show -no-color tfplan > tfplan.txt'
                    }
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
                 withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir('terraform') {
                        sh 'terraform apply -input=false tfplan'
                    }
                }
            }
        }
        stage('Refresh kubeconfig') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-creds'
        ]]) {
            sh '''
                mkdir -p /var/lib/jenkins/.kube

                # Always remove old kubeconfig
                rm -f /var/lib/jenkins/.kube/config

                # Generate fresh kubeconfig
                aws eks update-kubeconfig \
                    --region us-east-1 \
                    --name demo-eks-cluster \
                    --kubeconfig /var/lib/jenkins/.kube/config

                echo "Verifying kubeconfig..."

                grep server /var/lib/jenkins/.kube/config
            '''
        }
    }
}
        stage('Update kubeconfig') {
             steps {
                        withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir('terraform') {
                        sh 'aws eks --region us-east-1 update-kubeconfig --name demo-eks-cluster'
                    }
                }
            }
        }

        stage('Update kubectl') {
             steps {
                        withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir('terraform') {
                        sh '''
                          curl -LO https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl
                          chmod +x kubectl
                          export PATH=$PWD:$PATH
                          ./kubectl version --client
                     '''
                    }
                }
            }
        }

        stage('Verify EKS Cluster') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-creds'
        ]]) {
            sh '''
                export KUBECONFIG=/var/lib/jenkins/.kube/config

                kubectl get nodes
            '''
        }
    }
}
        
    }
}
