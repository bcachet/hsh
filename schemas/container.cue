package schemas

// Define the container image to be deployed
#Container: {
	registry: string | "docker.io" | *"ghcr.io" | "quay.io"
	name!:    string
	tag:      string | *"latest"
	args?: [...string]
	resources?: [string | "memory" | "cpu"]: string
}
