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

        
 stage('Terraform Apply') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-creds'
        ]]) {
            dir('terraform') {
                sh '''
                    terraform apply -input=false tfplan
                '''
            }
        }
    }
}

stage('Configure kubectl & Update kubeconfig') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-creds'
        ]]) {
            dir('terraform') {
                sh '''
                    set -e

                    CLUSTER_NAME="demo-eks-cluster"
                    AWS_REGION="us-east-1"

                    # Get EKS Kubernetes version
                    K8S_VERSION=$(aws eks describe-cluster \
                        --name ${CLUSTER_NAME} \
                        --region ${AWS_REGION} \
                        --query "cluster.version" \
                        --output text)

                    echo "EKS Cluster Version: ${K8S_VERSION}"

                    # Download matching kubectl only if missing
                    if [ ! -f kubectl ]; then
                        echo "Downloading kubectl v${K8S_VERSION}.0 ..."
                        curl -LO https://dl.k8s.io/release/v${K8S_VERSION}.0/bin/linux/amd64/kubectl
                        chmod +x kubectl
                    fi

                    export PATH=$PWD:$PATH

                    mkdir -p /var/lib/jenkins/.kube

                    aws eks update-kubeconfig \
                        --region ${AWS_REGION} \
                        --name ${CLUSTER_NAME} \
                        --kubeconfig /var/lib/jenkins/.kube/config

                    echo "kubectl version:"
                    kubectl version --client

                    echo "Kubeconfig updated successfully."
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
            dir('terraform') {
                sh '''
                    set -e

                    export PATH=$PWD:$PATH
                    export KUBECONFIG=/var/lib/jenkins/.kube/config

                    echo "AWS Identity"
                    aws sts get-caller-identity

                    echo "Cluster Info"
                    kubectl cluster-info

                    echo "Cluster Nodes"
                    kubectl get nodes -o wide

                    echo "Namespaces"
                    kubectl get ns
                '''
            }
        }
    }
}        
    }
}
