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
	mkdir: {
		for workloadName, workload in backends.quadlet {
			"mkdir-\(workloadName)": file.Mkdir & {
				createParents: true
				path: "./workloads/\(workloadName)/"
			}
		}
	}
	
	for workloadName, workload in backends.quadlet {
		
		// Export .kube file
		"write-\(workloadName)-kube": file.Create & {
			dep: mkdir.$done
			filename: "workloads/\(workloadName)/\(workloadName).kube"
			contents: workload.kube.output
		}
		
		// Export .network file
		"write-\(workloadName)-network": file.Create & {
			dep: mkdir.$done
			filename: "workloads/\(workloadName)/\(workloadName).network"
			contents: workload.network.output
		}
		
		// Export .yaml file
		"write-\(workloadName)-yaml": file.Create & {
			dep: mkdir.$done
			filename: "workloads/\(workloadName)/\(workloadName).yaml"
			contents: yaml.Marshal(workload.yaml.output)
		}
	}
}
