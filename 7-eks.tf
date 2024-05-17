resource "aws_iam_role" "my_eks_role" {
  name               = "MyEKSClusterRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "my_eks_policy_attachment" {
  role       = aws_iam_role.my_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "my_eks_node_role" {
  name               = "MyEKSNodeRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "my_eks_node_policy_attachment" {
  role       = aws_iam_role.my_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "my_eks_cni_policy_attachment" {
  role       = aws_iam_role.my_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.my_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_cluster" "my_cluster" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.my_eks_role.arn
  version  = "1.29"

  vpc_config {
    endpoint_private_access   = true
    endpoint_public_access    = false
    subnet_ids = [aws_subnet.private_zone1.id, aws_subnet.private_zone2.id]
  }

  tags = {
    Name = "MyEKSCluster"
  }
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "worker-nodes"
  node_role_arn   = aws_iam_role.my_eks_node_role.arn
  subnet_ids      = [aws_subnet.private_zone1.id, aws_subnet.private_zone2.id]
  instance_types  = ["t3.medium"]
  capacity_type   = "SPOT"

  scaling_config {
    desired_size = 2  # Update with your desired node count
    max_size     = 2  # Update with your desired max node count
    min_size     = 1  # Update with your desired min node count
  }

  depends_on = [
    aws_iam_role_policy_attachment.my_eks_node_policy_attachment,
    aws_iam_role_policy_attachment.my_eks_cni_policy_attachment,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}
