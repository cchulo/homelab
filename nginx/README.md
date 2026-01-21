#Instructions

- install quadlet folder contents to ~/.config/containers/systemd
- install firewalld contents to /etc/firewalld/services
- in addition, we need to enable port-fowarding from 443 to 8443 to make https work:
```bash
sudo firewall-cmd --permanent --add-forward-port=port=443:proto=tcp:toport=8443:toaddr=
sudo firewall-cmd --reload
```
