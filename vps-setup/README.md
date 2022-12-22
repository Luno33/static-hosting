# VPS Setup

### Prerequisites

- Set the env var of the user you login with in the VPS
  
  ```
  export LOGIN_USER=************
  ```

- Create a file named `./ansible/hosts` with this structure
  
  ```
  [server01]
  XXX.XXX.XXX.XXX ansible_ssh_user=************
  ```
    - `XXX.XXX.XXX.XXX` is your server's IP address
    - `************` is the user to login with

## Test the connection

```
cd ./ansible
ansible-playbook ./test-connection.yml -i hosts
```

## Run the setup

```
cd ./ansible
ansible-playbook ./setup.yml -i hosts
```

To send ssh key password and sudo password use:

```
cd ./ansible
ansible-playbook ./setup.yml -i hosts -kK
```

## Run the services

This command needs to be runned inside the VPS

```
sudo docker compose up
```
