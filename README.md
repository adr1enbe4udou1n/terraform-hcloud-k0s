# Terraform Hetzner Cloud K0S

## :dart: About

Get a powerful HA-ready Kubernetes cluster in less than **5 minutes** for less than **$30/month**, with easy configuration setup through simple Terraform variables, 💯 GitOps compatible !

This Terraform template will generate a ready-to-go cloud infrastructure through Hetzner Cloud provider, with a ready-to-install [K0S](https://k0sproject.io/), a zero-friction Kubernetes distribution. By default, when using [this example file](terraform.tfvars.example) without any changes except required variables, the cluster will be created with following resources :

1. **1 main control pane** server as Kubernetes controller with the pre-configured K0S installer
2. **2 worker nodes**
3. **1 load balancer** for HA with above workers as targets, balancing 80 and 443 TCP port (L4 protocol)
4. **1 data node** tainted for any Data/DB specific tasks
5. **1 10GB volume** mounted on data node

All nodes use **CX21** server type by default (configurable, cf below for advanced configuration).
Total price of this default setup : 5.88 \* 4 + 0.48 \* 1 = **$29,88** / month.

Note as the first 3 points are the absolute minimal setup for a viable HA Kube setup. You can get rid of data + volume and go down to **$23,52**.

Additional controllers and workers can be easily added thanks to terraform variables, even after initial setup for **easy upscaling**, enabling complete **GitOps infrastructure management**. Feel free to fork this project in order to adapt for your custom needs.

### Networking and firewall

All nodes including LB will be linked with a proper private network as well as **solid firewall protection**. Only the 1st main control pane node will have open ports for SSH (port **2222**) and kube-apiserver (port **6443**) for admin management. Other internal nodes will be accessed by SSH Jump. **IP whitelist** is supported by simple TF variable.

### OS management

This Terraform template includes **[Salt Project](https://docs.saltproject.io)** as well for easy global OS management of the cluster through ssh, perfect for upgrades in one single time ! The NFS client is also installed by default for any usage through remote NFS server for stateful workloads.

## :white_check_mark: Requirements

Before starting, you need to have :

1. A Hetzner cloud account.
2. A `terraform` client. On Windows, this is a simple `scoop install terraform`.
3. Optionally access to a DNS on any registrar is recommended.

Before continue, **DO NOT** reuse any existing hcloud project as we'll use terraform !

## :checkered_flag: Starting

### Prepare

The first thing to do is to prepare a new hcloud project :

1. Create a new **EMPTY** hcloud empty project.
2. Generate a **Read/Write API token key** to this new project according to [this official doc](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/).

Then create your own repo from this template and clone it locally.

### Setup

We firstly need to generate a cluster dedicated ssh key in order to allow [k0sctl](https://github.com/k0sproject/k0sctl) to install k0s on all nodes remotely.

> Note as this ssh key is only intended for internal cluster usage.

Now it's time for initial cluster setup :

```bash
# generate internal cluster ssh key
ssh-keygen -t ed25519 -f keys/id_cluster -qN=

# copy default exemple variables
cp terraform.tfvars.example terraform.tfvars
```

Next fill required variables :

| Name              | Default      | Description                                                             |
| ----------------- | ------------ | ----------------------------------------------------------------------- |
| hcloud_token      |              | The above token generated from hcloud project                           |
| server_image      | ubuntu-22.04 | Bare OS server of nodes                                                 |
| server_type       | nbg1         | Cluster location                                                        |
| my_public_ssh_key |              | Your own public ssh key in order to login to any node of the cluster    |  |
| cluster_name      | kube         | Name of the cluster, must be simple alphanum + hyphen + underscore      |
| cluster_user      | kube         | Default UID 1000 sudoer user                                            |
| cluster_fqdn      |              | Fully qualified domain name of your cluster, where you have DNS control |

You can stay with the default configs for other variables, but don't worry, as we're using Terraform it can be changed easily after cluster installation ❤️

Go to the [main variables](vars.tf) file for all available variables.

### Installation

Finally, you're ready to initiate installation by only few terraform standard steps :

```bash
# check plan
terraform plan

# apply plan
terraform apply
```

## Usage

Once terraform installation is complete, terraform will output the SSH config necessary to connect to your cluster for each node as well as 2 public IPs :

* `cluster_ip` dedicated to cluster management through SSH and Kubernetes API
* `lb_ip` as main IP to use for your web services accessible through 80 and 443 ports

Go to your registrar and edit DNS entry named as above `cluster_fqdn` and point it to `cluster_ip`. Then copy the SSH config to your own SSH config, default to `~/.ssh/config`.

Then you can finally use `ssh <cluster_name>` in order to log in to your main control pane node. For other nodes, the control pane node will be used as a bastion for direct access to other nodes, so you can use for example `ssh <cluster_name>-worder-01` to directly access to your *worker-01* node.

### Salt

Once logged to your main controller, don't forget to active *Salt*, just type `sudo salt-key -A` in order to accept all minions. You are now ready for using `sudo salt '*' pkg.upgrade` from main control pane in order to upgrade all nodes in one single time.

> If salt-key command is not existing, wait few minutes as it's necessary that cloud-init has finished his job.

### Kubernetes

#### K0S install

Once successfully logged, note the `k0sctl.yaml` file automatically generated in your home directory. You're now finally ready to install your Kubernetes cluster by simply launching `k0sctl apply` !

> If you get any random error, try again, k0sctl is not 100% reliable... Be sure to have SSH access to other nodes with `ssh data-01 -p2222 -i .ssh/id_cluster`

After successful install, you should have access to your shiny new K0S instance. Type `sudo k0s kubectl get nodes -o wide` to check node status and be sure all nodes is ready and have proper private IPs.

#### Remote kube-apiserver access

In order to connect remotely to your K0S cluster, use `k0sctl kubeconfig` in order to print all token connection and merge it to your local kubectl client (default to `~/.kube/config`). Finally, use `kubectl config use-context <cluster_name>` and you're ready to go !

> I highly encourage you to use <https://github.com/shanoor/kubectl-aliases-powershell> (bash) or <https://github.com/ahmetb/kubectl-aliases> (PS) for better CLI experience.

## Cluster configuration

This template support many cluster typologies thanks to cluster related variables.

TODO

## :memo: License

This project is under license from MIT. For more details, see the [LICENSE](https://adr1enbe4udou1n.mit-license.org/) file.

Made with :heart: by <a href="https://github.com/adr1enbe4udou1n" target="_blank">Adrien Beaudouin</a>
