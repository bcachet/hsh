package schemas

import (
	"strconv"
)

// Define how a Workload is exposed to others
#Expose: {
	ports!: [Port=string]: #Port & {
		if strconv.Atoi(Port) != _|_ {
			containerPort: strconv.Atoi(Port)
		}
	}
}

#Port: {
	// Port the application listens on inside the container
	containerPort!: int

	// External port to expose
	hostPort?: int

	domain: string

	portType: string | *"TCP" | "UDP"
}
