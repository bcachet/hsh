package backends

import (
	"list"
	"strings"
	"github.com/bcachet/hsh/workloads"
)

// Quadlet backend generates Podman Quadlet files (.kube, .network, .yaml)
quadlet: {
	for workloadName, workload in workloads.workloads {
		"\(workloadName)": {
			// Generate .kube file
			kube: #QuadletKube & {
				_name: workloadName
				_workload: workload
			}
			
			// Generate .network file
			network: #QuadletNetwork & {
				_name: workloadName
				_workload: workload
			}
			
			// Generate .yaml file (Kubernetes Pod manifest)
			yaml: #KubernetesPod & {
				_name: workloadName
				_workload: workload
			}
		}
	}
}

// Quadlet .kube file format
#QuadletKube: {
	_name: string
	_workload: _

	// Add Traefik-specific sysctl and security settings
	_traefikSettings: string
	if _name == "traefik" {
		_traefikSettings: "Sysctl=net.ipv4.ip_unprivileged_port_start=0\nSecurityLabelType=container_runtime_t\n"
	}
	if _name != "traefik" {
		_traefikSettings: ""
	}

	output: """
		[Kube]
		Yaml=\(_name).yaml
		Network=\(_name).network
		Network=dmz.network
		\(_traefikSettings)
		[Install]
		WantedBy=default.target

		[Service]
		Restart=on-failure
		"""
}

// Quadlet .network file format
#QuadletNetwork: {
	_name: string
	_workload: _
	
	output: """
		[Unit]
		Description=\(strings.ToTitle(_name)) Network
		
		[Network]
		Driver=bridge
		Internal=false
		NetworkName=\(_name)
		"""
}

// Kubernetes Pod manifest (YAML)
#KubernetesPod: {
	_name: string
	_workload: _
	
	// Build Traefik labels from expose configuration
	_traefikLabels: {
		"traefik.enable": "true"
		"traefik.docker.network": "dmz"
		
		// Generate labels for each domains
		for portNum, port in _workload.expose.ports {
			if port.domain != _|_ {
				"traefik.http.routers.\(strings.Split(port.domain, ".")[0]).rule": "Host(`\(port.domain)`)"
				"traefik.http.routers.\(strings.Split(port.domain, ".")[0]).entrypoints": "https"
				"traefik.http.routers.\(strings.Split(port.domain, ".")[0]).tls": "true"
				"traefik.http.routers.\(strings.Split(port.domain, ".")[0]).tls.certresolver": "letsencrypt"
				"traefik.http.services.\(strings.Split(port.domain, ".")[0]).loadbalancer.server.port": "\(port.containerPort)"
				"traefik.http.routers.\(strings.Split(port.domain, ".")[0]).service": strings.Split(port.domain, ".")[0]
			}
		}
	}
	
	// Build container ports
	_containerPorts: [
		for portNum, port in _workload.expose.ports {
			{
				containerPort: port.containerPort
				protocol: port.portType
				if port.hostPort != _|_  {
					hostPort: port.hostPort
				}
			}
		}
	]
	
	// Build environment variables
	_containerEnvs: [
		for envName, envValue in _workload.envs {
			{
				name: envName
				value: envValue
			}
		}
	]
	
	// Build volume mounts
	_volumeMounts: list.Concat([
		// Regular volumes
		[for volumeName, volume in _workload.volumes {
			{
				name: "\(_name)-\(volumeName)"
				mountPath: "\(volume.mount):z"
			}
		}],
	])
	
	// Build volumes
	_volumes: list.Concat([
		// emptyDir volumes
		[for volumeName, volume in _workload.volumes if volume.type == "emptyDir" {
			{
				name: "\(_name)-\(volumeName)"
				emptyDir: {}
			}
		}],
		// hostPath volumes
		[for volumeName, volume in _workload.volumes if volume.type == "hostPath" {
			{
				name: "\(_name)-\(volumeName)"
				hostPath: {
					path: volume.source
				}
			}
		}],
		// PVC volumes
		[for volumeName, volume in _workload.volumes if volume.type == "PVC" {
			{
				name: "\(_name)-\(volumeName)"
				persistentVolumeClaim: {
					claimName: "\(_name)-\(volumeName)"
				}
			}
		}],
	])
	
	output: {
		apiVersion: "v1"
		kind: "Pod"
		metadata: {
			name: _name
			labels: {
				app: _name
			} & _traefikLabels
		}
		spec: {
			restartPolicy: "OnFailure"
			containers: [{
				name: _name
				image: "\(_workload.container.registry)/\(_workload.container.name):\(_workload.container.tag)"
				
				if len(_containerPorts) > 0 {
					ports: _containerPorts
				}
				
				if len(_containerEnvs) > 0 {
					env: _containerEnvs
				}
				
				if len(_volumeMounts) > 0 {
					volumeMounts: _volumeMounts
				}
				
				if _workload.container.args != _|_ {
					args: _workload.container.args
				}
				if _workload.container.resources != _|_ {
					resources: {
						limits: {
							if _workload.container.resources.memory != _|_ {
								memory: _workload.container.resources.memory
							}
							if _workload.container.resources.cpu != _|_ {
								cpu: _workload.container.resources.cpu
							}
						}
					}
				}
			}]
			
			if len(_volumes) > 0 {
				volumes: _volumes
			}
		}
	}
}
