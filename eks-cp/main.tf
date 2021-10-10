/*
  Trust policy to allow EKS service to
  assume our IAM role
*/
data "aws_iam_policy_document" "control_plane" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

/*
  IAM role to be used by EKS to interact with
  our account.
*/
resource "aws_iam_role" "control_plane" {
  name = "EKSControlPlane-${var.cluster_full_name}"
  assume_role_policy = "${data.aws_iam_policy_document.control_plane.json}"
}

/*
  Attach the required policies to the EKS IAM role
*/
resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.control_plane.name}"
}

resource "aws_iam_role_policy_attachment" "eks_service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.control_plane.name}"
}

/*
  Security Group for EKS network interfaces
*/
resource "aws_security_group" "control_plane" {
  name        = "${var.cluster_full_name}-control-plane"
  description = "EKS Cluster ${var.cluster_full_name}"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.cluster_full_name}",
    "kubernetes.io/cluster/${var.cluster_full_name}" = "owned",
  }
}

/*
  Create the EKS cluster
*/
resource "aws_eks_cluster" "control_plane" {
  name            = "${var.cluster_full_name}"
  role_arn        = "${aws_iam_role.control_plane.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.control_plane.id}"]
    subnet_ids         = ["${concat(var.private_subnets, var.public_subnets)}"]
  }

  version = "${var.cluster_version}"

  depends_on = [
    "aws_iam_role_policy_attachment.eks_service",
    "aws_iam_role_policy_attachment.eks_cluster",
    "aws_cloudwatch_log_group.eks_log_group",
  ]
}

resource "aws_cloudwatch_log_group" "eks_log_group" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  Name              = "${/aws/eks/var.cluster_full_name/cluster}"
  retention_in_days = 7
}
