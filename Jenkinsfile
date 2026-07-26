pipeline {

    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
       
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
        
    stage('Configure kubeconfig') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-creds'
        ]]) {
            sh '''
                set -e

                CLUSTER_NAME="demo-eks-cluster"
                AWS_REGION="us-east-1"

                echo "===== AWS Identity ====="
                aws sts get-caller-identity

                echo "===== kubectl Version ====="
                which kubectl
                kubectl version --client

                mkdir -p /var/lib/jenkins/.kube

                rm -f /var/lib/jenkins/.kube/config

                aws eks update-kubeconfig \
                    --region ${AWS_REGION} \
                    --name ${CLUSTER_NAME} \
                    --kubeconfig /var/lib/jenkins/.kube/config

                echo "===== Current Context ====="
                KUBECONFIG=/var/lib/jenkins/.kube/config kubectl config current-context

                echo "Kubeconfig updated successfully."
            '''
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
                set -e

                export KUBECONFIG=/var/lib/jenkins/.kube/config

                echo "===== AWS Identity ====="
                aws sts get-caller-identity

                echo "===== kubectl ====="
                which kubectl
                kubectl version --client

                echo "===== Current Context ====="
                kubectl config current-context

                echo "===== Cluster Info ====="
                kubectl cluster-info

                echo "===== Cluster Nodes ====="
                kubectl get nodes -o wide

                echo "===== Namespaces ====="
                kubectl get ns
            '''
        }
    }
}
 stage('Validate EKS Resources') {
    steps {
        sh '''
            export KUBECONFIG=/var/lib/jenkins/.kube/config

            echo "===== Nodes ====="
            kubectl get nodes

            echo "===== System Pods ====="
            kubectl get pods -n kube-system

            echo "===== Services ====="
            kubectl get svc -A
        '''
    }
}
        
    }
}
