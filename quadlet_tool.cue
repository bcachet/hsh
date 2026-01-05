package tools

import (
	"tool/file"
	"encoding/yaml"
	"path"
	"github.com/bcachet/hsh/workloads"
	"github.com/bcachet/hsh/backends"
)

// Export all Quadlet files for all workloads
command: quadlet: {
	// Generate config files first
	generateConfig: {
		for k, deployment in workloads.workloads {
			for kc, config in deployment.configs {
				mkdir: file.Mkdir & {
					createParents: true
					path: ".generated/\(k)-\(kc)/"
				}
				write: file.Create & {
					$dep: mkdir.$done
					filename: ".generated/\(k)-\(kc)/\(path.Base(config.mount))"
					contents: config.data
				}
			}
		}
	}
	
	// Generate Quadlet files
	for workloadName, workload in backends.quadlet {
		// Export .kube file
		"write-\(workloadName)-kube": file.Create & {
			if generateConfig != _|_ {
				$dep: generateConfig.$done
			}
			filename: "workloads/\(workloadName)/\(workloadName).kube"
			contents: workload.kube.output
		}
		
		// Export .network file
		"write-\(workloadName)-network": file.Create & {
			if generateConfig != _|_ {
				$dep: generateConfig.$done
			}
			filename: "workloads/\(workloadName)/\(workloadName).network"
			contents: workload.network.output
		}
		
		// Export .yaml file
		"write-\(workloadName)-yaml": file.Create & {
			if generateConfig != _|_ {
				$dep: generateConfig.$done
			}
			filename: "workloads/\(workloadName)/\(workloadName).yaml"
			contents: yaml.Marshal(workload.yaml.output)
		}
	}
}
