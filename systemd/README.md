#Instructions

- install systemd folder contents to ~/.config/containers/systemd
- install firewalld services and zones contents into /etc/firewalld
- in addition, we need to enable port-fowarding from 443 to 8443 to make https work:
```bash
sudo firewall-cmd --permanent --add-forward-port=port=443:proto=tcp:toport=8443:toaddr=
sudo firewall-cmd --reload
```
