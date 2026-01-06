package tools

import (
	"tool/file"
	"encoding/yaml"
	// "github.com/bcachet/hsh/workloads"
	"github.com/bcachet/hsh/backends"
)

// Export all Quadlet files for all workloads
command: quadlet: {	
	// Generate Quadlet files
	for workloadName, workload in backends.quadlet {
		"mkdir-\(workloadName)": file.MkdirAll & {
			path: "workloads/\(workloadName)/"
		}

		// Export .kube file
		"write-\(workloadName)-kube": file.Create & {
			$after: [command.quadlet["mkdir-\(workloadName)"]]
			filename: "workloads/\(workloadName)/\(workloadName).kube"
			contents: workload.kube.output
		}

		// Export .network file
		"write-\(workloadName)-network": file.Create & {
			$after: [command.quadlet["mkdir-\(workloadName)"]]
			filename: "workloads/\(workloadName)/\(workloadName).network"
			contents: workload.network.output
		}

		// Export .yaml file
		"write-\(workloadName)-yaml": file.Create & {
			$after: [command.quadlet["mkdir-\(workloadName)"]]
			filename: "workloads/\(workloadName)/\(workloadName).yaml"
			contents: yaml.Marshal(workload.yaml.output)
		}
	}
}
