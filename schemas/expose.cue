package schemas

import (
	"strconv"
)

// Define how a Workload is exposed to others
#Expose: {
	ports!: [Port=string]: #Port & {
	  containerPort: strconv.Atoi(Port)
	}
}

#Port: {
	// Port the application listens on inside the container
	containerPort!: int

	// Domain name associated to the service exposed on this port
	domain?: string

	// External port to expose
	hostPort?: int
}
