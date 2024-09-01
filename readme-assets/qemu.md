# QEMU

## MacOs with Apple Silicon (MX series)

### VM installation and configuration

How to configure a new machine and run it. Before executing the below commands, download a debian image and put it in the folder and it should be automatically in the folder `$HOME/Downloads/debian-12.6.0-amd64-netinst.iso`.

```bash
# Install qemu
brew install qemu

# Create image
qemu-img create -f qcow2 $HOME/VMs/debian-12.6.0-amd64-netinst.qcow2 10G

# Download the debian image and place it in the same folder with the same filename
mv $HOME/Downloads/debian-12.6.0-amd64-netinst.iso $HOME/VMs/debian-12.6.0-amd64-netinst.iso

# Run VM, first boot
qemu-system-x86_64 \
  -cpu qemu64 \
  -m 4G \
  -drive file=$HOME/VMs/debian-12.6.0-amd64-netinst.qcow2,format=qcow2 \
  -cdrom $HOME/VMs/debian-12.6.0-amd64-netinst.iso \
  -boot d \
  -vga virtio \
  -usb -device usb-tablet \
  -net nic -net user \
  -smp cores=4

# Run VM, after the debian installation configuration
# !!! the ifname parameter might change from system to system, en0 should be the default one !!!
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

Compact monitor console

```bash
# Enter the console
ctrl + option + 2

# Take a vm snapshot
(qemu) savevm snapshot-debian-v6-fixed-timezone

# List snapshots
(qemu) info snapshots

# Load snapshot
(qemu) loadvm snapshot-debian-v6-fixed-timezone

# Remove snapshot
(qemu) delvm snapshot-debian-v6-fixed-timezone

# Exit from the compact monitor console
ctrl + option + 1
```

Sometimes, using snapshot, the time will desync. To force a time sync run inside the VM

```bash
sudo systemctl restart systemd-timesyncd
```

### How to use it as a target of Ansible to it

Since MacOS does not include sshpass, a way to send ansible commands without installing additional software is to use ansible inside docker

```bash
# From the ./vps-setup/ansible folder
docker run -it --rm -v ./:/app/ alpinelinux/ansible:latest sh
> apk add --no-cache sshpass
> cd app
> export ANSIBLE_HOST_KEY_CHECKING=False
```

Now you can run the playbooks following the guide at [vps-setup/README.md](../vps-setup/README.md)

Files in the folder `./vps-setup/ansible` are mounted in the container, so every modification of the files on the host machine will be reflected inside the container.

## Find the VM IP Address once logged in

```bash
hostname -I
```
