#!/bin/bash

for lambda in $(ls -d ./cmd/*)
do
    GOOS=linux GOARCH=amd64 go build -o ${lambda}/main $(find "${lambda}" -name *.go | grep -v "_test.go")
    package="${lambda/"./cmd/"/""}"
    zip -jFS "./bin/${package}.zip" "${lambda}/main"
done

cd terraform
terraform apply -var-file=var/default.tfvars