# Home Sweet Home

## Objectives

Objective is to create a server with following services:
- Ad Blocker
  - [AdGuard Home](https://adguard.com/en/adguard-home/overview.html)
  - [Pi-Hole]()
- Filter inappropriate web content
  - [AdGuard Home](https://adguard.com/en/adguard-home/overview.html)
- Password Manager
  - [VaultWarden](https://github.com/dani-garcia/vaultwarden)
  - [BitWarden Lite](https://github.com/bitwarden/self-host/tree/main/bitwarden-lite)
- Backup to Exoscale SOS
  - [Restic](https://restic.net/)

I plan to deploy each services via containers.
I can rely on a managed Kubernetes solution like [Exoscale SKS offering](https://www.exoscale.com/sks/).
I would easily find Helm charts (official or not) for the various services I plan to use.

But I want to use this opportunity to learn things.

## Podman Quadlets

In the initial implementation, I plan to rely on the following:
- Podman Quadlet to run workloads in Podman containers as systemd services
- Cuelang to define workloads
- Export workload definition to Cuelang structure that represent [Podman Quadlet resources](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
- Generate Podman Quadlet Kube files out of Cuelang Podman Quadlet structure (via [text/template package](https://cuelang.org/docs/howto/use-text-template-execute-to-generate-text-from-data/))
- [Podman REST API](https://docs.podman.io/en/latest/_static/api.html) to deploy Podman Quadlets to targeted hosts
- Handle HTTP requests through [tool/http package](https://pkg.go.dev/cuelang.org/go/pkg/tool/http)
- Traefik as reverse DNS

> [!NOTE]
> [crei](https://github.com/lugoues/creidhne) allows to generate Podman Quadlet systemd units files from CUE data
> It may be a good source of inspiration

## Zero downtime

In a second stage, I would like to implement zero downtime on top of this approach via one of the following approach
- [Podman socket activation](https://github.com/containers/podman/blob/main/docs/tutorials/socket_activation.md) + 
  [systemd-socket-proxyd](https://www.man7.org/linux/man-pages/man8/systemd-socket-proxyd.8.html) for services 
  that do not support socket activation natively.

  Inspiration:
  - https://www.redhat.com/en/blog/painless-services-implementing-serverless-rootless-podman-and-systemd
  - https://thinkaboutit.tech/posts/2025-07-20-adhoc-containers-with-systemd-and-quadlet/

- Blue/Green deployment relying on Traefik & scripts to stop _old_ deployment

  Inspiration:
  - https://github.com/evolutics/zero-downtime-deployments-with-podman-docker-or-docker-compose
  - https://github.com/dryaf/deploy


# Quick start
## Terraform
```sh
cd terraform
terraform init
terraform plan
terraform apply
```

## Cue
```sh
cue cmd compose | tee docker-compose.yml && docker-compose up -d
cue cmd quadlet # Generate Quadlet files in workloads/{workload} directories
```
