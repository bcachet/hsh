package schemas

#Secret: {
	// Name of the Podman secret to reference
	name!: string

	// How the secret should be exposed in the container
	type!: "env" | "mount"

	// For type="env": environment variable name
	if type == "env" {
		envName!: string
	}

	// For type="mount": mount path (defaults to /run/secrets/<name>)
	if type == "mount" {
		mountPath?: string
	}
}

// Convenience types
#SecretEnv: #Secret & {
	type: "env"
}

#SecretMount: #Secret & {
	type: "mount"
}
