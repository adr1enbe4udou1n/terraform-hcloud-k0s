# Terraform K0S Hetzner Installer

## :dart: About ##

Basic terraform project for generating a ready to go Ubuntu 22.04 based cloud infrastructure through Hetzner Cloud provider, with a ready-to-install [K0S](https://k0sproject.io/), a zero-friction Kubernetes distribution. The cluster will be composed of 4 servers :

1. A main control pane server
2. 2 worker nodes
3. 1 data node for DB specific tasks

Feel free to add some additional nodes inside `servers.tf` file.

## :white_check_mark: Requirements ##

Before starting :checkered_flag:, you need to have a Hetzner cloud account as well as the `terraform` client. On Windows, this is a simple `scoop install terraform`.

## :checkered_flag: Starting ##

```bash
# Clone this project
$ git clone https://github.com/adr1enbe4udou1n/terraform-hetzner-kube-sample

# Prepare variables
cp terraform.tfvars.example terraform.tfvars

# Install
terraform apply
```

## Variables reference

TODO

## :memo: License ##

This project is under license from MIT. For more details, see the [LICENSE](https://adr1enbe4udou1n.mit-license.org/) file.

Made with :heart: by <a href="https://github.com/adr1enbe4udou1n" target="_blank">Adrien Beaudouin</a>
