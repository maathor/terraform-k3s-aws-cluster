data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}

#############################
### IAM Agent
#############################

resource "aws_iam_instance_profile" "agent_instance_profile" {
  name = format("%sAgentInstanceProfile", title(var.name))
  role = aws_iam_role.agent_role.name
}

resource "aws_iam_role" "agent_role" {
  name               = format("%sAgentRole", title(var.name))
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_role_policy_attachment" "agent_cloudwatch_server_policy" {
  count      = var.enable_ssm == true ? 1 : 0
  role       = aws_iam_role.agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "agent_ssm_instance_core_policy" {
  count      = var.enable_ssm == true ? 1 : 0
  role       = aws_iam_role.agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


#############################
### IAM Server
#############################
resource "aws_iam_instance_profile" "server_instance_profile" {
  name = format("%sServerInstanceProfile", title(var.name))
  role = aws_iam_role.server_role.name
}

resource "aws_iam_role" "server_role" {
  name               = format("%sServerRole", title(var.name))
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_role_policy_attachment" "server_cloudwatch_server_policy" {
  count      = var.enable_ssm == "true" ? 1 : 0
  role       = aws_iam_role.server_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "server_ssm_instance_core_policy" {
  count      = var.enable_ssm == "true" ? 1 : 0
  role       = aws_iam_role.server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
