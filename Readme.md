# Overview

This repository contains Infrastructure as Code (IaC) and tools to assist in the deployment of a NodeJS web application using [Terraform](https://www.terraform.io/), [AWS](https://aws.amazon.com/), and [Docker](https://www.docker.com/).

## Project requirements

- use Terraform set up a simple web app on Amazon EC2;
- the web app:
  - is load balanced using an ELB;
  - connects to an RDS instance;
- the RDS instance is not exposed to public connections;
- use EFS for shared storage between the two nodes;
- add a CloudWatch alarm that triggers when the total number of requests exceeds X
- setup ECS autoscaling

---

## The "Why" -s:

- **Why use Terraform?** - Terraform allows deploying, keeping track, and maintaining, cloud infrastructure and infrastructure resources.
- **Why AWS?** - AWS offers a vast array of cloud infrastructure resources that supports the deployment of applications. It's one of the most used cloud service providers. For the purpose of this exercise, AWS provides all the necessary resources, as well as resources that can be used on expanding the security, scalability, and flexibility of the project.

- **Why Docker?** - Docker is a software platform that allows building, testing, and deploying applications quickly. Docker packages software into standardized units called containers that have everything the software needs to run including libraries, system tools, code, and runtime .

## Prerequisites:

0. Install `tfenv` at the latest version
1. Install Terraform version `1.2.3` with tfenv `tfenv install 1.2.3`
2. Configure AWS credentials and confirm access to a remote state

## Workflow:

0. Clone this repo & cd into it
1. Generate a pair of SSH keys using `ssh-keygen` and place them in `[path/to/repo]/ssh`
2. Create an AWS S3 bucket that's going to be used for storing the Terraform state
3. In the `backend` block of the `terraform` configuration block in `/main.tf`, fill in:

   - the name of the bucket
   - the aws region to deploy the configuration in

4. Run `terraform init`
5. Run `./entrypoint.sh [your db password here]`\*. The password should be at least 8 chars long. The full deployment flow takes about 15 minutes to complete
6. Wait for about 3-4 minutes before opening the outputted Load Balancer URL;

---

_\*) **Important!** The value of `ECR_REPO_NAME` in `/entrypoint.sh` **must** be the same as the terraform variable `resource_identifier` in `/variables.tf`_

# Repo structure & concept:

## Birdseye view

The infrastructure consists entirely of AWS resources configured in Terraform modules. It deploys the NodeJS application in `/app` on ECS using [Fargate](https://aws.amazon.com/fargate/). The ECS cluster is deployed behind a Load Balancer. Based on the CPU and Memory usage, ECS will scale the deployment up or down.

The application itself consists of two endpoints - `/smashes` and `/smash` - that send `GET` and `POST` requests, respectively. It connects to a MySQL database in an AWS RDS instance to read and insert records from a single table called `smashes`. As the web page is loaded, the app requests the total count of smashes. Via having the `SMASH` button clicked, it inserts a new smash (row) and requests the total count of smashes again.

## Folder structure

```
├── app
│   ├── public
│   │   ├── client.js
│   │   └── index.html
│   ├── app.js
│   └── package.json
├── bin
│   ├── build_dk_image.sh
│   └── push_dk_image_to_ecr.sh
├── db
│   └── db_init.sql
├── modules
│   ├── EC2_bastion
│   │   ├── external
│   │   │   └── ssh_key.sh
│   │   ├── key_pair.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── ECR
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── ECS
│   │   ├── autoscaling.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── EFS
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── RDS
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── VPC
│       ├── cloudwatch.tf
│       ├── load_balancer.tf
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── ssh
├── utils
│   ├── add_ip_to_known_hosts.sh
│   ├── create_s3_bucket.sh
│   ├── force_new_ecs_deployment.sh
│   ├── init_db.sh
│   └── ssh_into_ec2.sh
├── Dockerfile
├── Readme.md
├── docker-compose.yaml
├── entrypoint.sh
├── .env
├── main.tf
├── outputs.tf
└── variables.tf
```

## Deployment flow

The entire deployment of the project is triggered by `/entrypoint.sh` where the execution is divided into three stages. The intention behind this was to have the ability to deploy the entire project with a single command.

Usually, this can be achieved by running `terraform apply`. This approach, however, would result in one (or more) failing ECS tasks. Since docker images are built locally and uploaded to remote repositories via processes external to Terraform, the provisioned ECS tasks end up looking for a docker image that does not exist in the specified ECR repo.

To mend this, the provisioning flow has to paused to "wait" for the docker image building and uploading to complete, and resume afterwards.

The `/entrypoint.sh` script takes care of this provisioning by targeting specific modules when applying the configuration. Once the ECR module is provisioned, the script calls `/bin/build_dk_image.sh` and `/bin/push_dk_image_to_ecr.sh`. Once they finish executing, the provisioning continues and the rest of the configuration is applied.

| Provisioning stage               | Done by                                                   |
| :------------------------------- | :-------------------------------------------------------- |
| Deploy VPC, RDS, ECR             | `/entrypoint.sh`                                          |
| Build docker image & push to ECR | `/bin/build_dk_image.sh` & `/bin/push_dk_image_to_ecr.sh` |
| Deploy ECR, EFS, EC2             | `/entrypoint.sh`                                          |

---

## Environment variables

The following environment variables are used in by the web app and, therefore, by ECS:

| Variable name  | Value                                                                                          |
| :------------- | :--------------------------------------------------------------------------------------------- |
| `RDS_PASSWORD` | Provded as an argument to`/entrypoint.sh`\.\* and passed to Terraform via the CLI `-var` flag. |
| `DB_NAME`      | Default value is set in `/variables.tf`\*\*                                                    |
| `RDS_HOSTNAME` | Outputted by the RDS module and injected as variables into the ESC module.                     |
| `RDS_PORT`     | Outputted by the RDS module and injected as variables into the ESC module.                     |
| `RDS_USERNAME` | Outputted by the RDS module and injected as variables into the ESC module.                     |

_\*) In a production environment, sensitive data, such as passwords, should not be stored publicly! It should always be stored in secure locations and/or handled by appropriate tools._

\_\*\*) **Important!** The value of `ECR_REPO_NAME` in `/entrypoint.sh` **must** be the same as the terraform variable `resource_identifier` in `/variables.tf`

## Seeding the database

Since the RDS instance is deployed in private VPC subnets, it is not accessible from the outside of the VPC. An EC2 instance is used to initialize the instance with the necessary database and table. The EC2 instance connects to RDS via an SSH connection and executes the SQL query in `/db/db_init.sql`\*. The SSH connection is possible via an EC2 key pair that's generated locally, on the machine that triggers the project provisioning. A designated security group that opens port 22 is attached to both the EC2 instance and the RDS instance.

The `smashes` table consists of the following fields:

| Field      | Type            | Null | Key | Default           | Extra             |
| :--------- | :-------------- | ---- | --- | ----------------- | ----------------- |
| id         | bigint unsigned | NO   | PRI | NULL              | auto_increment    |
| created_at | timestamp       | NO   |     | CURRENT_TIMESTAMP | DEFAULT_GENERATED |

\*_) In a production environment, database dumps/backups should **always** be stored in a secure location! A database dump is stored in this repository for demonstration purposes only._

## ECS Autoscaling

The autoscaling\* of the tasks running the web app is based on CPU and Memory usage. Since the NodeJS app is tiny, to see the autoscaling in action, the resources requested from ECS are set to a low number and so are the target values of the app autoscaling policies:

```terraform
container_definitions = [{
    [...]
    "cpu": 256,
    "memory": 512
    [...]
  }]
```

```terraform
locals {
  metrics = [
    {
      name                   = "cpu",
      target                 = 15,
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    },
    {
      name                   = "memory",
      target                 = 10,
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  ]
}

resource "aws_appautoscaling_policy" "policy" {
  count = length(local.metrics)

  [...]

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = local.metrics[count.index].predefined_metric_type
    }

    target_value = local.metrics[count.index].target
  }
}
```

</details>

_\*) **Note:** The tasks that have been deployed due to autoscaling will be **removed** when if the ECS cluster is updated. I.e., if the Terraform configuration is reapplied, the number of tasks will drop to 1, as per the `desired_count` parameter of the ECS service. The `desired_count` parameter should be set, as if it is not, it defaults to `null`, which results in the deprovisioning off all tasks on reapplying the TF configuration._

## Cloudwatch alarm

A CloudWatch alarm is set to track the number of requests hitting the ELB targets. To trigger a state change, it is set to track 10-minute periods. If the number of requests is higher than 20 for any given single period, it will go in an `ALARM` state. Currently, there are no actions attached to the it.

```terraform
resource "aws_cloudwatch_metric_alarm" "requests_alarm" {
  [...]
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  threshold           = "5"
  period              = "600"
}
```

## Tearing down the infrastructure

Since Terraform is used for infrastructure provisioning, tearing everything down can be done by running one of the following commands at the root level of this repository:

- `terraform destroy -var db_password="your_db_password"` - Wait for the confirmation prompt, type `yes`, and press Enter;
- `terraform apply -destroy -var db_password="your_db_password" -auto-approve`, if you don't feel like waiting for confirmation. **Warning: This will destroy all provisioned resources without waiting for approval!**

---

## Misc

- Run `terraform state list` at the root level of this repo to check the current state of the infrastructure deployed by Terraform.

- A `docker-compose` file is available for local development/testing. Note that to run the app locally, a `.env` file with the required environment variables should be present at the root level of the repository.

- There are a few additional utility scripts in `/utils`:

| Script                        | Arguments                                                                                         | Purpose                                                                                                                   |
| :---------------------------- | :------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| `add_ip_to_known_hosts.sh`    | `$1` - a public IP address                                                                        | Adding an ip the local known hosts. <br/> To be used before `ssh_into_ec2.sh`                                             |
| `create_s3_bucket.sh `        | `$1` - the name of the <br/> `$2` - AWS region                                                    | Creates an S3 bucket. <br/> An S3 bucket is required by this Terraform configuration to have the its state stored into it |
| `force_new_ecs_deployment.sh` | `$1` - AWS region <br/> `$2` - AWS account id <br/> `$3` - cluster name <br/> `$4` - service name | Updates and ECS service.                                                                                                  |
| `init_db.sh`                  | N/A                                                                                               | Executes `/db/db_init.sql` into a MySQL server. <br/> Uses the `connection_params` output from `module.rds`               |
| `ssh_into_ec2.sh`             | `$1` - a public IP address that                                                                   | Connects to an EC2 instance. <br/> The instance' IP address has to be added to the known hosts first                      |

---

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                   | Version |
| ------------------------------------------------------ | ------- |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 4.22 |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | 4.67.0  |

## Modules

| Name                                                                 | Source                | Version |
| -------------------------------------------------------------------- | --------------------- | ------- |
| <a name="module_ec2_bastion"></a> [ec2_bastion](#module_ec2_bastion) | ./modules/EC2_bastion | n/a     |
| <a name="module_ecr"></a> [ecr](#module_ecr)                         | ./modules/ECR         | n/a     |
| <a name="module_ecs"></a> [ecs](#module_ecs)                         | ./modules/ECS         | n/a     |
| <a name="module_efs"></a> [efs](#module_efs)                         | ./modules/EFS         | n/a     |
| <a name="module_rds"></a> [rds](#module_rds)                         | ./modules/RDS         | n/a     |
| <a name="module_vpc"></a> [vpc](#module_vpc)                         | ./modules/VPC         | n/a     |

## Resources

| Name                                                                                                                          | Type        |
| ----------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name                                                                                       | Description                                   | Type     | Default            | Required |
| ------------------------------------------------------------------------------------------ | --------------------------------------------- | -------- | ------------------ | :------: |
| <a name="input_aws_region"></a> [aws_region](#input_aws_region)                            | The region to provision resources in          | `string` | `"eu-west-1"`      |    no    |
| <a name="input_db_password"></a> [db_password](#input_db_password)                         | The password of the DB user                   | `string` | n/a                |   yes    |
| <a name="input_db_username"></a> [db_username](#input_db_username)                         | The username to be used for the RDS root used | `string` | `"swo"`            |    no    |
| <a name="input_resource_identifier"></a> [resource_identifier](#input_resource_identifier) | A name to identify AWS resources by           | `string` | `"swo-assignment"` |    no    |

## Outputs

| Name                                                                                               | Description                                                               |
| -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| <a name="output_connection_params"></a> [connection_params](#output_connection_params)             | Formatted string used to crate a database and a table in the RDS instance |
| <a name="output_ec2_public_ip"></a> [ec2_public_ip](#output_ec2_public_ip)                         | The ID if the AWS account                                                 |
| <a name="output_load_balancer_address"></a> [load_balancer_address](#output_load_balancer_address) | The addresses of the load balancer                                        |
| <a name="output_rds_hostname"></a> [rds_hostname](#output_rds_hostname)                            | RDS instance hostname                                                     |
| <a name="output_rds_port"></a> [rds_port](#output_rds_port)                                        | RDS instance port                                                         |
| <a name="output_rds_username"></a> [rds_username](#output_rds_username)                            | RDS instance root username                                                |

<!-- END_TF_DOCS -->
