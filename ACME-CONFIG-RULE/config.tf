variable "destination_bucket_config" {
  default = "acme-test-me-south-config-bucket"
}

#### IAM for config recorder

resource "aws_iam_role" "BP" {
  name = "AWS-ConfigRecorderRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name        = "AWS-Config-Rule-policy"
  description = "Custom Policy to collect the config rule"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.destination_bucket_config}/AWSLogs/*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "cloudtrail:List*",
                "cloudtrail:Desc*",
                "config:Put*",
                "cloudtrail:Look*",
                "cloudtrail:Get*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.destination_bucket_config}"
        }
    ]
}
EOF
}



data "aws_iam_policy" "read2" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

# data "aws_iam_policy" "read3" {
#   arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# }




resource "aws_iam_role_policy_attachment" "read" {
  role       = "${aws_iam_role.BP.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}
resource "aws_iam_role_policy_attachment" "read-2" {
  role       = "${aws_iam_role.BP.name}"
  policy_arn = "${data.aws_iam_policy.read2.arn}"
}

# resource "aws_iam_role_policy_attachment" "read-3" {
#   role       = "${aws_iam_role.BP.name}"
#   policy_arn = "${data.aws_iam_policy.read3.arn}"
# }

resource "aws_config_configuration_recorder" "ConfigurationRecorder" {
  role_arn = "${aws_iam_role.BP.arn}"#"arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWS-ConfigRecorderRole"

  recording_group {
    all_supported = true
    include_global_resource_types = true
  }
  #depend_on = ["${aws_iam_role.BP}"]
}

resource "aws_config_delivery_channel" "DeliveryChannel" {
  s3_bucket_name = "${aws_s3_bucket.a.id}"#"${var.logaccountbucket}" # Log Account Bucket name
  #s3_key_prefix  = "${var.s3_key_prefix}"
  depends_on = [ "aws_config_configuration_recorder.ConfigurationRecorder" ]
}



resource "aws_config_configuration_recorder_status" "ConfigurationRecorderStatus" {
  name = "${aws_config_configuration_recorder.ConfigurationRecorder.name}"
  is_enabled = true
  depends_on = [ "aws_config_delivery_channel.DeliveryChannel" ]
}



#########################
# CONFIG RULE S3 Bucket
#########################

resource "aws_s3_bucket" "a" {
  bucket = "${var.destination_bucket_config}"
  acl    = "private"
  #prefix = "AWSLogs"
  tags = {
    Owner        = "BAPCO"
    Support      = "ACME"
  }
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
			"Sid": "AWSConfigBucketPermissionsCheck",
			"Effect": "Allow",
			"Principal": {
				"Service": "config.amazonaws.com"
			},
			"Action": "s3:GetBucketAcl",
			"Resource": "arn:aws:s3:::${var.destination_bucket_config}"
		},
		{
			"Sid": "AWSConfigBucketDelivery",
			"Effect": "Allow",
			"Principal": {
				"Service": "config.amazonaws.com"
			},
			"Action": "s3:PutObject",
			"Resource": "arn:aws:s3:::${var.destination_bucket_config}/AWSLogs/*/*"
		},
		{
			"Sid": "Enforce HTTPS Connections",
			"Effect": "Deny",
			"Principal": "*",
			"Action": "s3:*",
			"Resource": "arn:aws:s3:::${var.destination_bucket_config}/*",
			"Condition": {
				"Bool": {
					"aws:SecureTransport": "false"
				}
			}
		},
		{
			"Sid": "Restrict Delete* Actions",
			"Effect": "Deny",
			"Principal": "*",
			"Action": "s3:Delete*",
			"Resource": "arn:aws:s3:::${var.destination_bucket_config}/*"
		}
	]
}
EOF
}


