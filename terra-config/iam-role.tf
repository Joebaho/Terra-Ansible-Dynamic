# IAM Role for Ansible Controller
resource "aws_iam_role" "ansible_ec2_role" {
  name = "AnsibleEC2InventoryRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_policy" "ansible_ec2_policy" {
  name        = "AnsibleEC2InventoryPolicy"
  description = "Allow Ansible to discover EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ansible_attach" {
  role       = aws_iam_role.ansible_ec2_role.name
  policy_arn = aws_iam_policy.ansible_ec2_policy.arn
}
resource "aws_iam_instance_profile" "ansible_instance_profile" {
  name = "AnsibleInstanceProfile"
  role = aws_iam_role.ansible_ec2_role.name
}
