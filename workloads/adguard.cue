package workloads

import (
    schemas "github.com/bcachet/hsh/schemas:schemas"
)

workloads: schemas.#Workloads & {
    adguard: schemas.#Workload & {
        container: {
            registry: "docker.io"
            name:     "adguard/adguardhome"
            tag: "latest"
            resources: {
                memory: "128Mi"
                cpu: "500m"
            }
        }
        expose: {
            ports: {
                "80": {
                    domain: "adguard-dashboard.host3d.org"
                },
                "3000": {
                    domain: "adguard-admin.host3d.org"
                },
                "53_tcp": {
                    containerPort: 53
                    hostPort: 53
                    portType: "TCP"
                },
                "53_udp": {
                    containerPort: 53
                    hostPort: 53
                    portType: "UDP"
                }
            }
        }
        volumes: {
            conf: schemas.#VolumePersistent & {
                mount: "/opt/adguardhome/conf"
            }
            work: schemas.#VolumePersistent & {
                mount: "/opt/adguardhome/work"
            }
        }
    }
}