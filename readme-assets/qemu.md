# QEMU

## Installation of the QA envinronment

### Download O.S.

How to configure a new machine and run it. Before executing the below commands, download an Ubuntu image from [here](https://ubuntu.com/download/server) and put it a the folder like `$HOME/Downloads/ubuntu-24.04.3-live-server-amd64.iso`.

### Install QEmu

#### On MacOs

```bash
# Install qemu
brew install qemu
```

#### On Linux

```bash
# Install qemu (https://www.qemu.org/download/#linux)
apt-get install qemu-system
```

### Create a QEmu disk image

This will be the "virtual hard drive" of the Virtual Machine

```bash
qemu-img create -f qcow2 $HOME/VMs/ubuntu-24.04.3-live-server-amd64.qcow2 10G
```

### Run the Ubuntu installation

#### On MacOS

> the ifname parameter might change from system to system, en0 should be the default one

```bash
qemu-system-x86_64 \
  -cpu qemu64 \
  -m 4G \
  -drive file=$HOME/VMs/ubuntu-24.04.3-live-server-amd64.qcow2,format=qcow2 \
  -cdrom $HOME/Downloads/ubuntu-24.04.3-live-server-amd64.iso \
  -boot d \
  -vga virtio \
  -usb -device usb-tablet \
  -net nic -net user \
  -smp cores=4
```

#### On Linux

```bash
qemu-system-x86_64 \
  -cpu qemu64 \
  -m 8G \
  -drive file=$HOME/VMs/ubuntu-24.04.3-live-server-amd64.qcow2,format=qcow2 \
  -cdrom $HOME/Downloads/ubuntu-24.04.3-live-server-amd64.iso \
  -boot c \
  -vga virtio \
  -usb -device usb-tablet \
  -nic user,model=virtio-net-pci,hostfwd=tcp::2222-:22 \
  -smp cores=4
```

### Install Ubuntu

1. Select the preferred language
2. Select the preferred keyboard
3. In the installation type, select `Ubuntu Server` and `Search for third-party drivers`
4. In the network configuration page, leave everything as it is if it managed to get a local IP address
5. On proxy address, skip
6. On the mirror for ubuntu, wait until the test is complete and, if successful, leave the default
7. On the storage configuration, select only `Use an entire disk` and make sure the installation will run on the disk you've created before
8. In the detailed storage configuration leave everything as default
9. Fill the Profile Configuration page with name, server name, username and password. The user needs to be the same as the `VPS_USER` in the file `.env.qa`. The username should be something else than `root`, as Ubuntu disables root SSH by default.
10. Skip Ubuntu pro
11. Install the OpenSSH server and allow password authentication over SSH
12. Do not select any snap to install, as we'll use ansible to install everything on the O.S.

### Install other software

#### On MacOS

> the ifname parameter might change from system to system, en0 should be the default one

```bash
sudo qemu-system-x86_64 \
  -cpu qemu64 \
  -m 4G \
  -drive file=$HOME/VMs/debian-12.6.0-amd64-netinst.qcow2,format=qcow2 \
  -boot c \
  -vga virtio \
  -usb -device usb-tablet \
  -nic vmnet-bridged,ifname=en0 \
  -smp cores=4
```

#### On Linux

```bash
qemu-system-x86_64 \
  -cpu qemu64 \
  -m 8G \
  -drive file=$HOME/VMs/ubuntu-24.04.3-live-server-amd64.qcow2,format=qcow2 \
  -boot c \
  -vga virtio \
  -usb -device usb-tablet \
  -nic user,model=virtio-net-pci,hostfwd=tcp::2222-:22 \
  -smp cores=4
```

After logging in, you'll find the local IPv4 address in the system information like this:

```bash
IPv4 address for ensX: 10.X.X.X
```

You can store that address under `VPS_ADDRESS` in `./envs/.env.qa`.

### How to use it as a target of Ansible to it

We'll need the environmental variable SSH_KEY_PATH, which is described [here](../vps-setup/README.md)

#### On MacOs

Since MacOS does not include sshpass, a way to send ansible commands without installing additional software is to use ansible inside docker

```bash
# From the ./vps-setup/ansible folder
docker run -it --rm -v ./:/app/ -v "${SSH_KEY_PATH}:${SSH_KEY_PATH}" -e SSH_KEY_PATH=${SSH_KEY_PATH} alpine/ansible:2.18.6 sh
> apk add --no-cache sshpass
> cd app
> export ANSIBLE_HOST_KEY_CHECKING=False
```

We are defining the port 2222 as it is the port we are binding when running qemu for SSH.

#### On Linux

```bash
sudo docker run -it --network host --rm -v ./:/app/ -v "${SSH_KEY_PATH}:${SSH_KEY_PATH}" -e SSH_KEY_PATH=${SSH_KEY_PATH} alpine/ansible:2.18.6 sh
> apk add --no-cache sshpass
> cd app
> export ANSIBLE_HOST_KEY_CHECKING=False
```

We are defining the port 2222 as it is the port we are binding when running qemu for SSH.

### Configure the hosts file

On `./vps-setup/ansible/hosts` write:

#### On MacOS

```bash
[server01]
<VPS_ADDRESS> ansible_ssh_user=<VPS_USER>
```

#### On Linux

```bash
[server01]
127.0.0.1 ansible_port=2222 ansible_ssh_user=<VPS_USER>
```

### Next Steps

Now you can run the playbooks following the guide at [vps-setup/README.md](../vps-setup/README.md)

Files in the folder `./vps-setup/ansible` are mounted in the container, so every modification of the files on the host machine will be reflected inside the container.

Use also the commands below to save snapshots for the VM.

## Compact monitor console

```bash
# Enter the console
ctrl + option (or alt on linux) + 2

# Take a vm snapshot
(qemu) savevm snapshot-ubuntu-v1

# List snapshots
(qemu) info snapshots

# Load snapshot
(qemu) loadvm snapshot-ubuntu-v1

# Remove snapshot
(qemu) delvm snapshot-ubuntu-v1

# Exit from the compact monitor console
ctrl + option + 1
```

Sometimes, using snapshot, the time will desync. To force a time sync run inside the VM

```bash
sudo systemctl restart systemd-timesyncd
```
