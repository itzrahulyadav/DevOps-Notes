# Terraform


### What is Infrastructure as Code(IaC)

- Infrastructure as Code is a practice where we write configuration scripts to automate creating,updating or destroying the cloud infrastructure.
- Infrastructure as Code allows us to use code to manage our infrastructure and remove the tedious task of provisioning,configuring and managing the infrastructure manually.


### What is Terraform ?
-  Terraform is an open source tool that allows to automate and manage the infrastructure,platform and the services that run on that platform.
-  Terraform uses declarative language means we only define our end result,we don't need to provide the steps how it's done.
- Terraform is idempodent which means even if we perform the same action many times it will always result in the same outcome.


#### Difference between Ansible and Terraform

| Ansible                                     | Terraform                               |
| ------------------------------------------- | ----------------------------------------|
|  mainly a configuration tool                | mainly a infra provisioning tool        |
|  more advanced                              | relatively new                          |


#### Terraform architecture 

Terraform has two main components

1. Core
- It uses two input sources
              - TF-config (what to create/configure)
              - TF state (current state of the infrastructure)
- It compares the current state and the desired state and decides what needs to be done to get to the desired state.

2. Providers
- These are the providers for cloud providers like AWS,Azure etc.
- Terraform has more than 100 providers.


__Example of configuration files__

```
#configuring the aws provider
provider "aws" {
   version = "~>2.0"
   region = "ap-south-1"
}

# Create a VPC
resource "aws_vpc" "example_vpc" {
   cidr_block = "10.0.0.0/16"
}

```

#### Difference between Declarative and imperative approach

1. Declarative
- We only define the end state in our config file.
- We don't need to define what to do.
- adjust the old config file and re-execute
- Clean and small config file
- we can always know the current state.

2. Imperative
- We need to define the step.



### Providers

Provider is a plugin that allows terraform to interact with external API's or services.

(Terraform) -----(provider)------> (AWS)

When you define a resource in your Terraform configuration file, you specify the type of resource and the provider responsible for managing that resource. For example, if you want to create an AWS EC2 instance, you would specify the "aws_instance" resource type and the "aws" provider.

The provider needs to be configured with the proper credentials before it can be used.

To install the provider we use the command `terraform init`

In terraform `.terraform.lock.hcl` is used to keep track of which providers are installed,their version etc.


#### Creating resources using terraform

_Syntax_

```
resource "<Resource_type>" "<Variable_name>" {
   ...........parameters,
   ...........parameters
}

```
- The name for each resource must be unique.

#### Data Sources

- It is a way to retrieve and read external data that is not managed by Terraform itself. A data source can be used to read information from a variety of sources, such as APIs, databases, or other services, and use that information to inform the creation and configuration of resources in Terraform.

- Data source can be used using the `data` block in your configuration file.
- For example:we can use data source to retrieve already existing vpc in aws that was not
created by terraform.

_syntax_

```
data "aws_vpc" "existing_vpc" {
   parameters....
   parameters....
}

```

### Destroying Resources

There are a couple of ways to destroy our resources

1. We can edit our file and remove the resources from the configuration file and use terraform apply.Terraform will compare the configuration and delete the resources based on the need.

2. We can use `terraform destroy` keyword to delete entire infrastructure.

or 

```
terraform destroy -target <resource_type>.<variable_name>

```

- Terraform stores the current state of the infrastucture.Terraform uses this file to
decide the current state and desired state specified in the configuration file.


### Terraform state

- This command is used to inspect and manage the state of our infrastructure.
- Here are the available commands

1. terraform state list: Lists all the resources that are being managed by Terraform.
2. terraform state show <resource>: Shows the current state of a specific resource.
3. terraform state pull: Pulls the latest state from the remote state storage and saves it to a local file.
4. terraform state push: Pushes the local state to the remote state storage.
5. terraform state rm <resource>: Removes a resource from the state.
6. terraform state mv <old-name> <new-name>: Renames a resource in the state.
7. terraform state replace-provider <type> <name> <new-type>: Replaces the provider for a given resource type.

### Terraform output

This are used to display or share data from the resources that we created.

This are used to access information about the resources like IP address or URL show that
we can use them in other resources or infrastructure.

_example_

```
output "public_ip" {
   value = aws_instance.example.public_ip;
}

```

This output value can be used in other part of the script using `${output.public_ip}`


### Input Variables

-  Variables are used to pass value to the configuration at run time.
-  Variables are declared using the `variable ` block.
-  It is recommended to declare your variables in `.tfvars` file.Terraform can referece it
automatically.
- We can also assign default values to the variables(will only be used if no value is provided)

_example_:

```
variable "region" {
  description = "The AWS region to create resources in"
  default = "ap-south-1"
}

```
The above variable can be accessed using `var` keyword.

```
resource "aws_instance" "example" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  region = var.region
}

```
- If we give our variable file any other name apart from `terraform.tfvars` then we need to pass the file name during command execution like this

```
terraform apply  -var-file <file_name>.tfvars

```

- we can also assign type constraint to our variables using the type key

```
variable "aws_region" {
   description = "region where you want to launch the resources"
   type = list(string)
}

```

### Terraform env variables

- export AWS_SECRET_ACCESS_KEY=<your AWS secret access key>
- export AWS_ACCESS_KEY_ID=<your AWS access key ID>

- AWS stores the credentials by default in the `~/.aws/credentials` folder.
- Just do aws configure and AWS will store the credentials in that folder.