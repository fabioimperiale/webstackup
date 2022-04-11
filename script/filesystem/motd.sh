### CHANGE MOTD ON UBUNTU BY WEBSTACKUP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/script/filesystem/motd.sh?$(date +%s) | sudo bash
#!/usr/bin/env bash

## Disable dynamic news ( https://motd.ubuntu.com/ )
##
sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news
