# FSx CSI Driver IAM Role for Service Account (IRSA)
module "fsx_csi_irsa" {
  source = "./modules/iam-service-account"

  count = var.create_eks && var.enable_aws_fsx_csi_driver_addon ? 1 : 0

  role_name                     = "fsx-csi-driver-${var.cluster_name}"
  role_description              = "IAM role for FSx CSI driver"
  provider_url                  = replace(aws_eks_cluster.this[0].identity[0].oidc[0].issuer, "https://", "")
  role_policy_document          = data.aws_iam_policy_document.fsx_csi_driver[0].json
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:fsx-csi-controller-sa"]

  tags = var.tags
}

# Reference AWS managed policy for FSx CSI driver
# AWS Documentation: https://docs.aws.amazon.com/eks/latest/userguide/fsx-csi-create.html
# Policy Reference: https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonFSxFullAccess.html
#
# AWS RECOMMENDATION: AWS officially recommends using the AmazonFSxFullAccess managed policy
# for the FSx CSI driver IAM role. From the EKS documentation:
# "Create an IAM role and attach the AWS managed policy with the following command"
# eksctl create iamserviceaccount --attach-policy-arn arn:aws:iam::aws:policy/AmazonFSxFullAccess
#
# This implementation uses source_policy_documents to reference the AWS managed policy,
# providing the same permissions while maintaining flexibility for future customizations.
#
# Current AmazonFSxFullAccess policy content (as of 2025-09-09):
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "ViewAWSDSDirectories",
#       "Effect": "Allow",
#       "Action": [
#         "ds:DescribeDirectories"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Sid": "FullAccessToFSx",
#       "Effect": "Allow",
#       "Action": [
#         "fsx:AssociateFileGateway",
#         "fsx:AssociateFileSystemAliases",
#         "fsx:CancelDataRepositoryTask",
#         "fsx:CopyBackup",
#         "fsx:CopySnapshotAndUpdateVolume",
#         "fsx:CreateAndAttachS3AccessPoint",
#         "fsx:CreateBackup",
#         "fsx:CreateDataRepositoryAssociation",
#         "fsx:CreateDataRepositoryTask",
#         "fsx:CreateFileCache",
#         "fsx:CreateFileSystem",
#         "fsx:CreateFileSystemFromBackup",
#         "fsx:CreateSnapshot",
#         "fsx:CreateStorageVirtualMachine",
#         "fsx:CreateVolume",
#         "fsx:CreateVolumeFromBackup",
#         "fsx:DetachAndDeleteS3AccessPoint",
#         "fsx:DeleteBackup",
#         "fsx:DeleteDataRepositoryAssociation",
#         "fsx:DeleteFileCache",
#         "fsx:DeleteFileSystem",
#         "fsx:DeleteSnapshot",
#         "fsx:DeleteStorageVirtualMachine",
#         "fsx:DeleteVolume",
#         "fsx:DescribeAssociatedFileGateways",
#         "fsx:DescribeBackups",
#         "fsx:DescribeDataRepositoryAssociations",
#         "fsx:DescribeDataRepositoryTasks",
#         "fsx:DescribeFileCaches",
#         "fsx:DescribeFileSystemAliases",
#         "fsx:DescribeFileSystems",
#         "fsx:DescribeS3AccessPointAttachments",
#         "fsx:DescribeSharedVpcConfiguration",
#         "fsx:DescribeSnapshots",
#         "fsx:DescribeStorageVirtualMachines",
#         "fsx:DescribeVolumes",
#         "fsx:DisassociateFileGateway",
#         "fsx:DisassociateFileSystemAliases",
#         "fsx:ListTagsForResource",
#         "fsx:ManageBackupPrincipalAssociations",
#         "fsx:ReleaseFileSystemNfsV3Locks",
#         "fsx:RestoreVolumeFromSnapshot",
#         "fsx:TagResource",
#         "fsx:UntagResource",
#         "fsx:UpdateDataRepositoryAssociation",
#         "fsx:UpdateFileCache",
#         "fsx:UpdateFileSystem",
#         "fsx:UpdateSharedVpcConfiguration",
#         "fsx:UpdateSnapshot",
#         "fsx:UpdateStorageVirtualMachine",
#         "fsx:UpdateVolume"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Sid": "CreateSLRForFSx",
#       "Effect": "Allow",
#       "Action": "iam:CreateServiceLinkedRole",
#       "Resource": "*",
#       "Condition": {
#         "StringEquals": {
#           "iam:AWSServiceName": [
#             "fsx.amazonaws.com"
#           ]
#         }
#       }
#     },
#     {
#       "Sid": "CreateSLRForLustreS3Integration",
#       "Effect": "Allow",
#       "Action": "iam:CreateServiceLinkedRole",
#       "Resource": "*",
#       "Condition": {
#         "StringEquals": {
#           "iam:AWSServiceName": [
#             "s3.data-source.lustre.fsx.amazonaws.com"
#           ]
#         }
#       }
#     },
#     {
#       "Sid": "CreateLogsForFSxWindowsAuditLogs",
#       "Effect": "Allow",
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Resource": [
#         "arn:aws:logs:*:*:log-group:/aws/fsx/*"
#       ]
#     },
#     {
#       "Sid": "WriteToAmazonKinesisDataFirehose",
#       "Effect": "Allow",
#       "Action": [
#         "firehose:PutRecord"
#       ],
#       "Resource": [
#         "arn:aws:firehose:*:*:deliverystream/aws-fsx-*"
#       ]
#     },
#     {
#       "Sid": "CreateTags",
#       "Effect": "Allow",
#       "Action": [
#         "ec2:CreateTags"
#       ],
#       "Resource": [
#         "arn:aws:ec2:*:*:route-table/*"
#       ],
#       "Condition": {
#         "StringEquals": {
#           "aws:RequestTag/AmazonFSx": "ManagedByAmazonFSx"
#         },
#         "ForAnyValue:StringEquals": {
#           "aws:CalledVia": [
#             "fsx.amazonaws.com"
#           ]
#         }
#       }
#     },
#     {
#       "Sid": "DescribeEC2VpcResources",
#       "Effect": "Allow",
#       "Action": [
#         "ec2:DescribeSecurityGroups",
#         "ec2:GetSecurityGroupsForVpc",
#         "ec2:DescribeSubnets",
#         "ec2:DescribeVpcs",
#         "ec2:DescribeRouteTables"
#       ],
#       "Resource": "*",
#       "Condition": {
#         "ForAnyValue:StringEquals": {
#           "aws:CalledVia": [
#             "fsx.amazonaws.com"
#           ]
#         }
#       }
#     },
#     {
#       "Sid": "ManageCrossAccountDataReplication",
#       "Effect": "Allow",
#       "Action": [
#         "fsx:PutResourcePolicy",
#         "fsx:GetResourcePolicy",
#         "fsx:DeleteResourcePolicy"
#       ],
#       "Resource": "*",
#       "Condition": {
#         "ForAnyValue:StringEquals": {
#           "aws:CalledVia": [
#             "ram.amazonaws.com"
#           ]
#         }
#       }
#     }
#   ]
# }
data "aws_iam_policy_document" "fsx_csi_driver" {
  count = var.create_eks && var.enable_aws_fsx_csi_driver_addon ? 1 : 0

  # Reference the AWS managed policy
  source_policy_documents = [
    data.aws_iam_policy.amazon_fsx_full_access[0].policy
  ]
}

# Get the AWS managed AmazonFSxFullAccess policy
data "aws_iam_policy" "amazon_fsx_full_access" {
  count = var.create_eks && var.enable_aws_fsx_csi_driver_addon ? 1 : 0
  arn   = "arn:aws:iam::aws:policy/AmazonFSxFullAccess"
}
