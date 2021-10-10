/*
  Template out a kubeconfig file for this cluster
*/
data "template_file" "kubeconfig" {
  template = "${file("${path.module}/kubeconfig.tpl")}"

  vars {
    cluster_name = var.cluster_name
    ca_data      = aws_eks_cluster.control_plane.certificate_authority.0.data
    endpoint     = aws_eks_cluster.control_plane.endpoint
  }
}

resource "local_file" "kubeconfig" {
  content = data.template_file.kubeconfig.rendered
  filename = "${path.module}/kubeconfig"
}

/*
  IAM policy for nodes
*/
data "aws_iam_policy_document" "kube2iam" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "node" {
  name   = "kube2iam"
  role   = "${aws_iam_role.node.id}"
  policy = "${data.aws_iam_policy_document.kube2iam.json}"
}

data "aws_iam_policy_document" "workers" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "workers" {
  name               = "${var.cluster_full_name}-EKSNode"
  assume_role_policy = "${data.aws_iam_policy_document.workers.json}"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_instance_profile" "workers" {
  name = "${var.cluster_full_name}-workers"
  role = aws_iam_role.workers.name
}

/*
  This config map configures which IAM roles should be trusted by Kubernetes
  Here we configure the IAM role assigned to the nodes to be in the
  system:bootstrappers and system:nodes groups so that the nodes
  may register themselves with the cluster and begin working.
*/
resource "local_file" "aws_auth" {
  content = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.workers.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
YAML
  filename = "${path.module}/aws-auth-cm.yaml"
  depends_on = ["local_file.kubeconfig"]

  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local_file.kubeconfig.filename} apply -f ${path.module}/aws-auth-cm.yaml"
  }
}

resource "aws_security_group_rule" "worker_to_worker_tcp" {
  description              = "Allow workers tcp communication with each other"
  from_port                = 0
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_to_worker_udp" {
  description              = "Allow workers udp communication with each other"
  from_port                = 0
  protocol                 = "udp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_masters_ingress" {
  description              = "Allow workes kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = var.cluster_security_group
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_masters_https_ingress" {
  description              = "Allow workers kubelets and pods to receive https from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = var.cluster_security_group
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "masters_api_ingress" {
  description              = "Allow cluster control plane to receive communication from workers kubelets and pods"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "masters_kubelet_egress" {
  description              = "Allow the cluster control plane to reach out workers kubelets and pods"
  from_port                = 10250
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 10250
  type                     = "egress"
}

resource "aws_security_group_rule" "masters_kubelet_https_egress" {
  description              = "Allow the cluster control plane to reach out workers kubelets and pods https"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 443
  type                     = "egress"
}

resource "aws_security_group_rule" "masters_workers_egress" {
  description              = "Allow the cluster control plane to reach out all worker node security group"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  type                     = "egress"
}

resource "aws_autoscaling_group" "workers" {
  name                = format("%s-workers-asg-%s", var.cluster_full_name, var.workers_instance_type)
  max_size            = var.workers_number_max
  min_size            = var.workers_number_min
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.workers.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = format("%s-workers-%s", var.cluster_full_name, var.workers_instance_type)
    propagate_at_launch = true
  }

  tag {
    key                 = format("kubernetes.io/cluster/%s", var.cluster_full_name)
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "Managedby"
    value               = "terraform"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "workers" {
  name_prefix            = format("%s-%s", var.cluster_full_name, var.workers_instance_type)
  instance_type          = var.workers_instance_type
  image_id               = var.workers_ami_id
  vpc_security_group_ids = [aws_security_group.workers.id]
  user_data              = base64encode(local.workers_userdata)

  iam_instance_profile {
    name = aws_iam_instance_profile.workers.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = "gp2"
      volume_size           = var.workers_storage_size
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "volume"
    tags          = var.common_tags
  }
}
