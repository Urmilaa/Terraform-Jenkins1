#####################################
# VPC MODULE
#####################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  ###################################
  # VPC Configuration
  ###################################

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs = [
    "us-east-1a",
    "us-east-1b"
  ]

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]

  ###################################
  # NAT Gateway
  ###################################

  enable_nat_gateway = true
  single_nat_gateway = true

  ###################################
  # DNS
  ###################################

  enable_dns_hostnames = true
  enable_dns_support   = true

  ###################################
  # Required EKS Subnet Tags
  ###################################

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  ###################################
  # Common Tags
  ###################################

  tags = {
    Terraform  = "true"
    Environment = "Dev"
    Project     = "EKS-Lab"
  }
}

#####################################
# EKS MODULE
#####################################

module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.2"

  ###################################
  # Cluster
  ###################################

  cluster_name    = var.cluster_name
  cluster_version = "1.34"

  ###################################
  # Networking
  ###################################

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  ###################################
  # Authentication
  ###################################

  enable_cluster_creator_admin_permissions = true

  ###################################
  # IAM Roles for Service Accounts
  ###################################

  enable_irsa = true

  ###################################
  # Control Plane Logs
  ###################################

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  ###################################
  # EKS Managed Add-ons
  ###################################

  cluster_addons = {

    coredns = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
    }

    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  ###################################
  # Managed Node Group
  ###################################

  eks_managed_node_groups = {

    default = {

      desired_size = 2
      min_size     = 1
      max_size     = 3

      instance_types = [
        "t3.micro"
      ]

      ami_type = "AL2023_x86_64_STANDARD"

      capacity_type = "ON_DEMAND"

      disk_size = 20

      #################################
      # Rolling Updates
      #################################

      update_config = {
        max_unavailable = 1
      }

      #################################
      # Kubernetes Labels
      #################################

      labels = {
        Environment = "Dev"
        NodeGroup   = "default"
      }

      #################################
      # EC2 Tags
      #################################

      tags = {
        Name = "${var.cluster_name}-default-nodegroup"
      }
    }
  }

  ###################################
  # Cluster Tags
  ###################################

  cluster_tags = {
    Environment = "Dev"
    Project     = "EKS-Lab"
  }

  ###################################
  # Common Tags
  ###################################

  tags = {
    Terraform  = "true"
    Environment = "Dev"
    Project     = "EKS-Lab"
  }
}
