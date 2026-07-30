# Home Sweet Home

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
In the initial implementation, I plan to rely on the following:
- Podman Quadlet to run workloads in Podman containers as systemd services
- Traefik as reverse DNS

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

I plan to define workload with Cuelang.
I will need to define Cuelang structure that represent Podman Quadlet Container:
- [Podman Quadlet Container definition](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
- [Generate text from data](https://cuelang.org/docs/howto/use-text-template-execute-to-generate-text-from-data/)
- [crei: Generate Podman Quadlet systemd units from CUE](https://github.com/lugoues/creidhne)

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
