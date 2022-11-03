resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "s3-role"
  assume_role_policy = jsonencode(var.assumerolepolicy)
}

resource "aws_iam_instance_profile" "test_profile2" {
    name  = "test_profile2"
    role = aws_iam_role.ec2_s3_access_role.name
}

resource "aws_iam_policy_attachment" "test-attach"{
  name = "test-attachment"
  roles = [aws_iam_role.ec2_s3_access_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
        ]
})
}
