#!/usr/bin/env bash
# vim: et ts=2 syn=bash
#
# Crowdsec system Extension.
#

function list_available_versions() {
  list_github_releases crowdsecurity cs-firewall-bouncer
}

function populate_sysext_root() {
  local sysextroot="$1"
  local arch="$2"
  local version="$3"

  local rel_arch="$(arch_transform "x86-64" "amd64" "$arch")"

  curl -fSsL -o crowdsec "https://github.com/crowdsecurity/cs-firewall-bouncer/releases/download/${version}/crowdsec-firewall-bouncer-linux-${rel_arch}.tgz"

  tar xzf crowdsec --strip-components=1

  mkdir -p "${sysextroot}/usr/local/bin/"
  mkdir -p "${sysextroot}/usr/share/crowdsec-firewall-bouncer/"

  cp "crowdsec-firewall-bouncer" "${sysextroot}/usr/local/bin/"

  cp config/crowdsec-firewall-bouncer.yaml    "${sysextroot}/usr/share/crowdsec-firewall-bouncer/"
  cp config/crowdsec-firewall-bouncer.service "${sysextroot}/usr/lib/systemd/system/"
}
