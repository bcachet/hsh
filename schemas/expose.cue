package schemas

import (
	"strconv"
)

// Define how a Workload is exposed to others
#Expose: {
	ports!: [Port=string]: #Port & {
	  containerPort: strconv.Atoi(Port)
	}
	certs?: [Name=string]: #Certificate & {
		commonName: Name
	}
}

#Port: {
	// Port the application listens on inside the container
	containerPort!: int

	// External port to expose
	exposedPort?: int
}

#Certificate: {
	// Common Name for the certificate
	commonName: string

	// Certificate TTL (e.g., "720h", "30d")
	ttl?: string
}
