#cloud-config
users:
  - name: okami
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ${public_ssh_key}

timezone: Europe/Paris
locale: fr_FR.UTF-8
package_update: true
package_upgrade: true
package_reboot_if_required: true
manage_etc_hosts: false

write_files:
  - path: /etc/hosts
    content: |
      10.0.0.2 kubedemo kubedemo.example.org
    append: true

runcmd:
  - sed -i "/^#Port/s/^.*$/Port 2222/" /etc/ssh/sshd_config
  - sed -i "/^PermitRootLogin/s/^.*$/PermitRootLogin no/" /etc/ssh/sshd_config
  - systemctl restart ssh
  - curl -o bootstrap-salt.sh -L https://bootstrap.saltproject.io
  - sh bootstrap-salt.sh
  - 'sed -i "s/#master: salt/master: kubedemo/" /etc/salt/minion'
  - systemctl restart salt-minion
