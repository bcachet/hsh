package workloads

import (
    schemas "github.com/bcachet/hsh/schemas:schemas"
)

workloads: schemas.#Workloads & {
    whoami: schemas.#Workload & {
        expose: {
            ports: "80": {
                domain: "whoami.host3d.org"
            }
        }
        container: {
            registry: "docker.io"
            name:     "traefik/whoami"
            tag: "latest"
            resources: {
                memory: "8Mi"
                cpu: "500m"
            }
        }
    }
}