---
title: Learning kubernetes the hard way
publish: true
---
> This tutorial walks you through setting up Kubernetes the hard way. This guide is not for someone looking for a fully automated tool to bring up a Kubernetes cluster. Kubernetes The Hard Way is optimized for learning, which means taking the long route to ensure you understand each task required to bootstrap a Kubernetes cluster.
> Kubernetes The Hard Way guides you through bootstrapping a basic Kubernetes cluster with all control plane components running on a single node, and two worker nodes, which is enough to learn the core concepts.

[https://github.com/kelseyhightower/kubernetes-the-hard-way/](Link to the official guide and github repository)

# Prerequisites

In this lab you will review the machine requirements necessary to follow this tutorial.

## Virtual or Physical Machines

This tutorial requires four (4) virtual or physical ARM64 or AMD64 machines running Debian 12 (bookworm). The following table lists the four machines and their CPU, memory, and storage requirements.

| Name    | Description            | CPU | RAM   | Storage |
|---------|------------------------|-----|-------|---------|
| jumpbox | Administration host    | 1   | 512MB | 10GB    |
| server  | Kubernetes server      | 1   | 2GB   | 20GB    |
| node-0  | Kubernetes worker node | 1   | 2GB   | 20GB    |
| node-1  | Kubernetes worker node | 1   | 2GB   | 20GB    |

## Provisioning the 4 machines

It is required to have 4 "real" machines here. Initially I wanted to use 4 docker images to reproduce the 4 machines but it is apparently not working because kubelet needs to run containers, so if kubelet itself runs inside a container, it needs to spawn containers inside a container. That's **Docker-in-Docker (DinD)**, which is problematic : the inner Docker daemon conflicts with the outer one, storage drivers clash, and you get subtle bugs.

Some tools such as _kind_ doesn't run Docker inside Docker. Instead each "node" container runs **containerd directly** (no Docker daemon), and kubelet talks to it via CRI.

The node containers run a real init system (`systemd` or `supervisord`) so kubelet can manage services normally. Volumes are handled via bind mounts from the host. Networking between nodes uses a Docker bridge network, and kind sets up its own CNI on top.

**What it doesn't solve**

- Kernel is still shared so no real isolation between "nodes"
- Can't test kernel-level stuff (eBPF, custom CNI edge cases, kernel params per node)

So for the sake of this tutorial it is better to provision "real" machines that do not run inside a docker container.

## Terraform

I've decided to use terraform to provision this 4 machines on a sandbox account of my company: here is the code

terraform.tf
```hcl
terraform {
  required_providers {
    aws = {
      version = "~> 6.4"
      source  = "hashicorp/aws"
    }
  }
  required_version = "~> 1.14.0"
}

```

main.tf
```hcl
provider "aws" {
  region = "eu-west-3"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "my_key" {
  key_name   = "x-key"
  public_key = file("~/.ssh/github_id_ed25519.pub")
}

locals {
  aws_instances = {
    "jumbox" = { desc = "administration host", instance_type = "t3.micro", storage_gb = 10 },
    "server" = { desc = "k8s server", instance_type = "t3.small", storage_gb = 20 },
    "node-0" = { desc = "k8s worker node 0", instance_type = "t3.small", storage_gb = 20 },
    "node-1" = { desc = "k8s worker node 1", instance_type = "t3.small", storage_gb = 20 },
  }
}


resource "aws_instance" "cluster" {
  for_each      = local.aws_instances
  ami           = data.aws_ami.ubuntu.id
  instance_type = each.value.instance_type

  root_block_device {
    volume_size = each.value.storage_gb
  }

  key_name = aws_key_pair.my_key.key_name

  tags = {
    "Name"        = each.key
    "Description" = each.value.desc
  }
}
```

They are created in the default vpc of the account which by default gives them a public ip address through the internet gateway in it.

You can get their public ip using this command after you can `terraform apply`

```shell
$ terraform show -json | jq '.values.root_module.resources[] | select(.type == "aws_instance") | {address: .address, public_ip: .values.public_ip}'

{
  "address": "aws_instance.cluster[\"jumbox\"]",
  "public_ip": "13.37.x.x"
}
{
  "address": "aws_instance.cluster[\"node-0\"]",
  "public_ip": "13.39.x.x"
}
{
  "address": "aws_instance.cluster[\"node-1\"]",
  "public_ip": "13.39.x.x"
}
{
  "address": "aws_instance.cluster[\"server\"]",
  "public_ip": "51.44.x.x"
}
```

You can then also modify your `~/.ssh/config`like this so it is easier to ssh into the 4 machines:

```ssh
Host jumpbox
	User ubuntu
	HostName 13.37.x.x
	IdentityFile ~/.ssh/github_id_ed25519
	IdentitiesOnly yes

Host server
	User ubuntu
	HostName 51.44.x.x
	IdentityFile ~/.ssh/github_id_ed25519
	IdentitiesOnly yes

Host node0
	User ubuntu
	HostName 13.39.x.x
	IdentityFile ~/.ssh/github_id_ed25519
	IdentitiesOnly yes

Host node1
	User ubuntu
	HostName 13.39.x/x
	IdentityFile ~/.ssh/github_id_ed25519
	IdentitiesOnly yes
```

By doing this you can just run `ssh jumbox|server|node0|node1`

