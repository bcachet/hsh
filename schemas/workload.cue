package schemas

#Workload: {
	name!:      string
	container!: #Container
	expose!:    #Expose
	configs: [string]: #Config
	volumes: [string]: #Volume
	envs:    [string]: string
	secrets: [string]: #Secret
	deps: [...#Workload]
}

#Workloads: [Name=string]: #Workload & {
	name: Name
}
