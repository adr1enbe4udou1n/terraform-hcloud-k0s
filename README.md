# Terraform K0S Hetzner Installer

## :dart: About ##

Basic terraform project for generating a ready to go Ubuntu 22.04 based cloud infrastructure through Hetzner Cloud provider, with a ready-to-install [K0S](https://k0sproject.io/), a zero-friction Kubernetes distribution. The cluster will be composed of 4 servers :

1. A main control pane server
2. 2 worker nodes
3. 1 data node for DB specific tasks

Feel free to add some additional nodes inside `servers.tf` file.

## :white_check_mark: Requirements ##

Before starting :checkered_flag:, you need to have a Hetzner cloud account as well as the `terraform` client. On Windows, this is a simple `scoop install terraform`.

Before continue, **DO NOT** reuse any existing project as we'll use terraform ! Create a new empty hcloud empty project with a valid Read/Write API token key.

## :checkered_flag: Starting ##

```bash
# Clone this project
$ git clone https://github.com/adr1enbe4udou1n/terraform-hetzner-kube-sample

# Prepare variables, cf bellow for list
cp terraform.tfvars.example terraform.tfvars

# Install
terraform apply
```

## Variables reference

| Name                       | Purpose                                                                                                                           |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| hcloud_token               | The token to access the Hetzner Cloud API (must have write access)                                                                |
| cluster_name               | Used for server names prefix, ${cluster_name}-controller-01, ${cluster_name}-worker-01, etc.                                      |
| cluster_user               | The default non root user for ssh connection                                                                                      |
| server_location            | At Nuremberg by default                                                                                                           |
| volume_size                | The size of volume that will be mounted to data node, 10Gb by default                                                             |
| my_public_ssh_name         |                                                                                                                                   |
| my_public_ssh_key          |                                                                                                                                   |
| my_ip_addresses            | IP addresses that will be whitelisted for SSH and Kubernetes API connection through Hetzner firewall, leave empty for free access |
| my_cluster_domain          |                                                                                                                                   |
| controller_ssh_key_name    |                                                                                                                                   |
| controller_private_ssh_key |                                                                                                                                   |
| controller_public_ssh_key  |                                                                                                                                   |

## Usage

TODO SSH Config
TODO Kube Cluster install

## :memo: License ##

This project is under license from MIT. For more details, see the [LICENSE](https://adr1enbe4udou1n.mit-license.org/) file.

Made with :heart: by <a href="https://github.com/adr1enbe4udou1n" target="_blank">Adrien Beaudouin</a>
