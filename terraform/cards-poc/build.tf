# locals {
#   lambdas = toset([
#     "go-test"
#   ])
# }

# resource "null_resource" "compile" {
#   for_each = local.lambdas
#   provisioner "local-exec" {
#     interpreter = ["bash", "-c"]
#     environment = {
#       GOARCH = "amd64"
#       GOOS   = "linux"
#     }
#     command = <<EOF
# go build $(ls ${local.path.src}/${each.key}/*.go | grep -v "test.go")
# EOF
#   }
# }

# data "archive_file" "package" {
#   for_each = local.lambdas
#   depends_on = [null_resource.compile]
#   type        = "zip"
#   source_dir = "${local.path.src}/${each.key}/main"
#   output_path = "${local.path.bin}/${each.key}.zip"
# }