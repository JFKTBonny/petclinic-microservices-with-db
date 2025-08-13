resource "aws_iam_role" "tf_jenkins_server_role" {
  name               = "jenkins_server_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecr_attach" {
  role       = aws_iam_role.tf_jenkins_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "cf_attach" {
  role       = aws_iam_role.tf_jenkins_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
}

resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.tf_jenkins_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


resource "aws_iam_instance_profile" "tf-jenkins-server-profile" {
  name = "jenkins-server-profile"
  role = aws_iam_role.tf_jenkins_server_role.name
}
