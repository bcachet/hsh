package workloads

import (
	schemas "github.com/bcachet/hsh/schemas:schemas"
)

workloads: schemas.#Workloads & {
	backup: schemas.#Workload & {
		container: {
			registry: "docker.io"
			name:     "restic/restic"
			tag:      "latest"
			resources: {
				memory: "512Mi"
				cpu:    "1000m"
			}
			// Run backup command on schedule
			// This will be overridden by systemd timer in production
			args: [
				"backup",
				"/volumes",
				"--host", "hsh-podman",
			]
		}

		// Non-sensitive environment variables (plain text)
		envs: {
			"RESTIC_REPOSITORY": "s3:sos-at-vie-1.exo.io/hsh-backups"
			"AWS_DEFAULT_REGION": "at-vie-1"
		}

		// Sensitive credentials via Podman secrets
		secrets: {
			exoscale_key: schemas.#SecretEnv & {
				name:    "exoscale-api-key"
				envName: "AWS_ACCESS_KEY_ID"
			}
			exoscale_secret: schemas.#SecretEnv & {
				name:    "exoscale-api-secret"
				envName: "AWS_SECRET_ACCESS_KEY"
			}
			restic_password: schemas.#SecretEnv & {
				name:    "restic-password"
				envName: "RESTIC_PASSWORD"
			}
		}

		volumes: {
			// Mount Podman volumes directory (read-only for safety)
			// This assumes rootless Podman with default user 1000
			volumes: schemas.#VolumeBind & {
				mount:  "/volumes"
				source: "/var/home/core/.local/share/containers/storage/volumes"
			}
			// Cache directory for Restic to improve performance
			cache: schemas.#VolumePersistent & {
				mount: "/root/.cache/restic"
			}
		}
		expose: {
			ports: {}
		}
	}
}
