package workloads

import (
    schemas "github.com/bcachet/hsh/schemas:schemas"
)

workloads: schemas.#Workloads & {
    traefik: schemas.#Workload & {
        container: {
            registry: "docker.io"
            name:     "library/traefik"
            tag:      "3"
            resources: {
                memory: "256Mi"
                cpu:    "500m"
            }
            args: [
                "--accesslog=true",
                "--log.level=info",
                "--api.dashboard=true",
                "--api.insecure=true",
                "--entrypoints.http.address=:80",
                "--entrypoints.http.http.redirections.entryPoint.to=https",
                "--entrypoints.http.http.redirections.entryPoint.scheme=https",
                "--entrypoints.https.address=:443",
                "--providers.docker=true",
                "--providers.docker.exposedbydefault=false",
                "--certificatesresolvers.letsencrypt.acme.email=bertrand.cache@gmail.com",
                "--certificatesresolvers.letsencrypt.acme.storage=/acme/acme.json",
                "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=http",
            ]
        }
        expose: {
            ports: {
                "80": {
                    hostPort: 80
                }
                "443": {
                    hostPort: 443
                }
            }
        }
        volumes: {
            socket: schemas.#VolumeBind & {
                mount:  "/var/run/docker.sock"
                source: "/run/user/1000/podman/podman.sock"
            }
            acme: schemas.#VolumePersistent & {
                mount: "/acme"
            }
        }
    }
}
