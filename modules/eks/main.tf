locals {
  name_prefix = "${var.project_name}-${terraform.workspace}"
  common_tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }

  scaling_config = {
    dev = {
      min = 1
      desired = 1
      max = 1
    }
    prod = {
      min = 1
      desired = 1
      max = 1
    }
  }
  #fallback
  current_scaling = lookup(local.scaling_config, terraform.workspace,local.scaling_config["dev"])
}

# ── Cluster IAM Role ──────────────────────────────────────────────────────────
resource "aws_iam_role" "cluster_role" {
  name = "${local.name_prefix}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ── Node Group IAM Role ───────────────────────────────────────────────────────
# Nodes are EC2 instances — so the principal is ec2.amazonaws.com, not eks
resource "aws_iam_role" "node_role" {
  name = "${local.name_prefix}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

# Nodes need 3 managed policies to join the cluster and function
resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ── EKS Cluster ───────────────────────────────────────────────────────────────
resource "aws_eks_cluster" "k8s_cluster" {
  name     = local.name_prefix
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids = var.private_subnet_ids   # worker nodes in private subnets only
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-cluster" })
}

# ── Managed Node Group ────────────────────────────────────────────────────────
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.k8s_cluster.name
  node_group_name = "${local.name_prefix}-nodes"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.private_subnet_ids  
  instance_types  = [var.instance_type]

  scaling_config {
    min_size     = local.current_scaling.min
    desired_size = local.current_scaling.desired
    max_size     = local.current_scaling.max
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_policy,
  ]

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-nodes" })
}