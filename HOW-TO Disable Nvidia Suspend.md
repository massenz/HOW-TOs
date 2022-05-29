# Solving Wake from Suspend Causes Dark Screen


Original article [here](https://forums.developer.nvidia.com/t/fixed-suspend-resume-issues-with-the-driver-version-470/187150); the TL;DR is "Nvidia Drivers 470.x use `systemctl` to wake from suspend, and that doesn't work."

The fix is to disable systemctl for Nvidia drivers:

```
sudo systemctl stop nvidia-suspend.service && \
     sudo systemctl stop nvidia-hibernate.service && \
     sudo systemctl stop nvidia-resume.service

sudo systemctl disable nvidia-suspend.service && \
     sudo systemctl disable nvidia-hibernate.service && \
     sudo systemctl disable nvidia-resume.service

sudo rm /lib/systemd/system-sleep/nvidia

sudo systemctl halt -f
```

