# CrowdSec Firewall Bouncer sysext

This extension ships the [CrowdSec Firewall Bouncer](https://docs.crowdsec.net/u/bouncers/firewall/).

CrowdSec provides a service unit which is included in this sysext. However, the service is not started 
automatically when the sysext is merged as the firewall backend must be specified and the bouncer registered 
with the local API.

## Usage

Download and merge the sysext at provisioning time using the below butane snippet.

The snippet includes automated updates via systemd-sysupdate.
Sysupdate will stage updates and request a reboot by creating a flag file at `/run/reboot-required`.
You can deactivate updates by changing `enabled: true` to `enabled: false` in `systemd-sysupdate.timer`.

Note that the snippet is for the x86-64 version of the crowdsec-firewall-bouncer v0.0.34.

Check out the metadata release at https://github.com/flatcar/sysext-bakery/releases/tag/crowdsec-firewall-bouncer for a list of all versions available in the bakery.

```yaml
variant: flatcar
version: 1.0.0

storage:
  files:
    - path: /opt/extensions/crowdsec-firewall-bouncer/crowdsec-firewall-bouncer.raw
      mode: 0644
      contents:
        source: https://extensions.flatcar.org/extensions/crowdsec-firewall-bouncer-v0.0.34-x86-64.raw
    - path: /etc/sysupdate.crowdsec-firewall-bouncer-v0.0.34.d/crowdsec-firewall-bouncer-v0.0.34-conf
      contents:
        source: https://extensions.flatcar.org/extensions/crowdsec-firewall-bouncer-v0.0.34-conf
    - path: /etc/sysupdate.d/noop.conf
      contents:
        source: https://extensions.flatcar.org/extensions/noop.conf
  links:
    - target: /opt/extensions/crowdsec-firewall-bouncer/crowdsec-firewall-bouncer-v0.0.34-x86-64.raw
      path: /etc/extensions/crowdsec-firewall-bouncer.raw
      hard: false
      
systemd:
  units:
    - name: systemd-sysupdate.timer
      enabled: true
    - name: systemd-sysupdate.service
      dropins:
        - name: crowdsec-firewall-bouncer.conf
          contents: |
            [Service]
            ExecStartPre=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/crowdsec-firewall-bouncer.raw > /tmp/crowdsec-firewall-bouncer"
            ExecStartPre=/usr/lib/systemd/systemd-sysupdate -C crowdsec-firewall-bouncer-v0.0.34 update
            ExecStartPost=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/crowdsec-firewall-bouncer.raw > /tmp/crowdsec-firewall-bouncer-new"
            ExecStartPost=/usr/bin/sh -c "if ! cmp --silent /tmp/crowdsec-firewall-bouncer /tmp/crowdsec-firewall-bouncer-new; then touch /run/reboot-required; fi"
```
