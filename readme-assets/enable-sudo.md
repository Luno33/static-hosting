# Enable Sudo

```bash
# Become root user
su

# Open /etc/sudoers file
nano /etc/sudoers
```

Locate the line `root ALL=(ALL:ALL) ALL` and write below it `user ALL=(ALL) ALL`, where `user` is the user that needs sudo permissions.

Save and exit.
