# Golang Cards POC

## Purpose
The goal of this project was to prepare a working example of microservice API built in Go. I haven't used Go before, so after finishing an online tutorial I decided to test this in practise and create a POC. The whole thing took ~10hrs (including tutorial), so the project is not as polished as it could.

The project exposes a BE REST API which simulates actions that could be done on a deck of cards. Deck could be created, shuffled, you could get a few cards from a deck, and of course remove it. There is no FE, but a sample Postman collection is provided.

The backend is done in AWS Serverless and using Terraform as IaC provider. Two golang microservices are deployed as AWS Lambda, connect to DynamoDb instance to store decks, and allow unrestricted TLS connectivity with AWS API Gateway connected with a domain.

## Project Structure

### Directories:

    bin - stores zipped linux executables to be uploaded to AWS Lambda
    cmd - stores 2 Lambda apps (deck-create-delete and deck-operate)
    internal - stores shared 'deck' module used by Lambdas in cmd
    postman - Postman collection to test the APIs
    terraform - infra resources to be deployed in AWS

### Files:

    ./deploy.sh - bash script used to build executables, pack into Lambda zips, then create infra and deploy Lambdas
    ./terraform/var/default.tf - terraform configuration which was used to deploy the original services 


## Building Project

### Prerequisites
To build and deploy everything from scratch, you'll need `terraform >= 1.1.9` and `go`. You'll need to override terraform variables in `terraform/var/default.tfvars` first, and initialize terraform by hitting:

    cd terraform
    terraform init

you might be asked about your AWS credentials and S3 bucket name to store terraform remote state.

### Build command
It might not be the usual Go way, but the project is built and deployed to AWS by executing in bash:
    
    ./deploy.sh
    
The Go executables (always for linux arch, always named `main`) are built in `cmd/<module_name>` . Then the executables are zipped and copied to `bin` as the final Lambda deliverables. From there they are pulled by terraform and pushed to AWS.

## Executing API Requests
You can use the Postman collection located in `postman` dir to quickly test APIs. The base API path for cards-poc microservices is

    https://cards.wild-card.consulting/api

Provided endpoints:

    POST /deck body: {"User": "string"}
    GET /deck queryParams: created-at=string&user=string
    PATCH /deck/shuffle body: {"User": "string", "CreatedAt": "string"}
    PATCH /deck/deal body: {"User": "string", "CreatedAt": "string", "N": "uint"}
    DELETE /deck body: {"User": "string", "CreatedAt": "string"}
