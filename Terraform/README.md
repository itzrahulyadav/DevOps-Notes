# Terraform


### What is Infrastructure as Code(IaC)

- Infrastructure as Code is a practice where we write configuration scripts to automate creating,updating or destroying the cloud infrastructure.
- Infrastructure as Code allows us to use code to manage our infrastructure and remove the tedious task of provisioning,configuring and managing the infrastructure manually.


### What is Terraform ?
-  Terraform is an open source tool that allows to automate and manage the infrastructure,platform and the services that run on that platform.
-  Terraform uses declarative language means we only define our end result,we don't need to provide the steps how it's done.


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



