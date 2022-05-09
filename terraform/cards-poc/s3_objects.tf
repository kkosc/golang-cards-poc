# locals {
#   versions = ["0.1.4", "0.2.0"]
#   config_files = {
#     "commit_schema": {
#       "key": "schemas/sub-exec-commit-schema.json"
#       "source": "${path.module}/templates/sub-exec-commit-schema.json"
#     }
#     "competition_schema": {
#       "key": "schemas/post-competitions-body-schema.json"
#       "source": "${path.module}/templates/post-competitions-body-schema.json"
#     }
#     "platform_supported_version": {
#       "key": "schemas/sub-exec-supported-versions.json"
#       "source": "${path.module}/templates/sub-exec-supported-versions.json"
#     }
#     "submission_service_wrapper": {
#       "key": "services/submission_run.py"
#       "source": "${path.module}/templates/submission_run.py"
#     }
#     "competition_service_wrapper": {
#       "key": "services/competition_run.py"
#       "source": "${path.module}/templates/competition_run.py"
#     }
#     "date_ranges": {
#       "key": "research-platform/date_ranges.json"
#       "source": "${path.module}/templates/date_ranges.json"
#     }
#     "bucket_map_0.1.4": {
#       "key": "research-platform/0.1.4/bucket-map.json"
#       "source": "${path.module}/templates/bucket-map-0.1.4.json"
#     }
#     "bucket_map_0.2.0": {
#       "key": "research-platform/0.2.0/bucket-map.json"
#       "source": "${path.module}/templates/bucket-map-0.2.0.json"
#     }
#     "bucket_map_prod_0.2.0": {
#       "key": "research-platform/0.2.0/bucket-map-prod.json"
#       "source": "${path.module}/templates/bucket-map-prod-0.2.0.json"
#     }
#     "platform_parameters_0.1.4": {
#       "key": "research-platform/0.1.4/platform-allowed-parameters.json"
#       "source": "${path.module}/templates/platform-allowed-parameters-0.1.4.json"
#     }
#     "platform_parameters_0.2.0": {
#       "key": "research-platform/0.2.0/platform-allowed-parameters.json"
#       "source": "${path.module}/templates/platform-allowed-parameters-0.2.0.json"
#     }
#     "platform_parameters_prod_0.2.0": {
#       "key": "research-platform/0.2.0/platform-allowed-parameters-prod.json"
#       "source": "${path.module}/templates/platform-allowed-parameters-prod-0.2.0.json"
#     }
#   }

# }

# resource "aws_s3_object" "configuration" {
#   for_each = local.config_files
#   bucket = var.s3_configuration_bucket
#   key    = each.value["key"]
#   source = each.value["source"]
#   source_hash = filemd5(each.value["source"])
# }