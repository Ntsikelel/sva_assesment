resource "aws_iam_role" "sva_role" {
  name = "sva-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "sva_ssm" {
  role       = aws_iam_role.sva_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "sva_cw" {
  role       = aws_iam_role.sva_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "sva_profile" {
  name = "sva-profile"
  role = aws_iam_role.sva_role.name
}

 