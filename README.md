# Terraform K0S Hetzner Installer

## :dart: About ##

Get a cheap but powerful Kubernetes instance in less than 5 minutes !

This Terraform template will generate a ready to go secured based cloud infrastructure through Hetzner Cloud provider, with a ready-to-install [K0S](https://k0sproject.io/), a zero-friction Kubernetes distribution. By default, the cluster will be composed of 4 **CX21** servers :

1. A main control pane server
2. 2 worker nodes
3. 1 data node for DB specific tasks with a separate volume (10 GB by default)

Total price : 5.88*4+0.48 = **$24** / month

Feel free to fork this project in order to adapt for your custom needs, with less or additional nodes, etc. This is just a startup sample template.

This Terraform template includes [Salt Project](https://docs.saltproject.io) as well for easy global cluster management, perfect for upgrades in one single time !

### Networking and firewall

All nodes will be linked with a proper private network as well as solid firewall protection. Only control pane node will have open ports. Other internal nodes will be accessed by SSH Jump.

The public firewall has 3 public ports for any services that you'll install in your K0S cluster, which are **22**, **80** and **443** (22 is useful for any services which needs SSH connection as Gitlab or any other VCS for project cloning).

The SSH connection will be made by port **2222** and Kubernetes API by port **6443**. Both admin ports can have IP whitelist.

> Note as the Hetzner Load Balancer is not used here in order to keep price low. So your control pane will be your main SPF if it's acceptable for you.

## :white_check_mark: Requirements ##

Before starting :checkered_flag:, you need to have a Hetzner cloud account as well as the `terraform` client. On Windows, this is a simple `scoop install terraform`. A valid custom domain on any registrar with access to his DNS is also recommended for easy access.

Before continue, **DO NOT** reuse any existing project as we'll use terraform ! Create a new empty hcloud empty project with a valid Read/Write API token key.

## :checkered_flag: Starting ##

After creating your repo from this template and cloned it locally :

```bash
# Prepare variables, cf bellow for list
cp terraform.tfvars.example terraform.tfvars

# Install
terraform apply
```

## Variables reference

| Name                       | Purpose                                                                                                                                                                                                |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| hcloud_token               | The token to access the Hetzner Cloud API (must have write access)                                                                                                                                     |
| cluster_name               | Used for server names prefix, ${cluster_name}-controller-01, ${cluster_name}-worker-01, etc.                                                                                                           |
| cluster_user               | The default non root user for ssh connection                                                                                                                                                           |
| cluster_fqdn               | User for main cluster FQDN access through Kubernetes API endpoint. This domain must be created on your own registrar and point towards the main controller IP                                          |
| server_location            | At Nuremberg by default                                                                                                                                                                                |
| volume_size                | The size of volume that will be mounted to data node, 10Gb by default                                                                                                                                  |
| my_public_ssh_name         | Name of default Hetzner ssh key                                                                                                                                                                        |
| my_public_ssh_key          | Your public SSH key for remote access to your nodes                                                                                                                                                    |
| my_ip_addresses            | IP addresses that will be whitelisted for SSH and Kubernetes API connection through Hetzner firewall. IP format must have full format with proper mask, e.i. x.x.x.x/32. Leave default for free access |
| controller_private_ssh_key | The private key of main controller server, required for k0sctl install                                                                                                                                 |
| controller_public_ssh_key  | The public key of main controller server                                                                                                                                                               |

Use the command `ssh-keygen -t ed25519 -f "cluster-key" -qN ""` for quick generation and put both content of private `cluster-key` and public `cluster-key.pub` keys into above respective `controller_private_ssh_key` and `controller_public_ssh_key` variables.

> You can legitimately think that the private SSH key through TF variable is unsecure, and you'll be right. But this is only intended for internal controller-to-worker access through private network, and cannot be used outside. All internal servers behind the main control pane node will be entirely blocked by the Hetzner firewall. If we need access to this internal nodes, we'll simply use the Jump SSH feature, and use controller node as bastion.

## Usage

Once terraform installation is complete, terraform will output the public IP main IP of the cluster as well as the SSH config necessary to connect to your cluster.

Go to your registrar and create new DNS entry named as above `cluster_fqdn` and point it to the printed public IP. Then integrate the SSH config to your own SSH config.

Finally, use `ssh <cluster_name>-cp` in order to log in to your main control pane node. For other nodes, the control pane node will be used as a bastion for direct access to other nodes, so you can use `ssh <cluster_name>-w1` to directly access to your worker-01 node.

### Salt

In order to active `Salt`, just type `sudo salt-key -A` in order to accept all minions. You are now ready for using `sudo salt '*' pkg.upgrade` from main control pane in order to upgrade all nodes in one single time.

### K0S

#### Install

Once successfully logged, note the `k0sctl.yaml` file automatically generated in your home directory. You're now finally ready to install your Kubernetes cluster by simply launching `k0sctl apply` !

> If you get any random error, try again, k0sctl is not 100% reliable... Be sure to have SSH access to other nodes with `ssh data-01 -p2222 -i .ssh/id_cluster`

After successfully install, you should have access to your shiny new K0S instance. Type `sudo k0s kubectl get nodes -o wide` to check node status and be sure all nodes is ready and have proper private IPs.

#### Remote access

In order to connect remotely to your K0S cluster, use `k0sctl kubeconfig` in order to print all token connection and merge it to your local kubectl client (default to `~/.kube/config`).

> I highly encourage you to use <https://github.com/shanoor/kubectl-aliases-powershell> (bash) or <https://github.com/ahmetb/kubectl-aliases> (PS) for better CLI experience.

## :memo: License ##

This project is under license from MIT. For more details, see the [LICENSE](https://adr1enbe4udou1n.mit-license.org/) file.

Made with :heart: by <a href="https://github.com/adr1enbe4udou1n" target="_blank">Adrien Beaudouin</a>
