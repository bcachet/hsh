package schemas

#Volume: {
    mount!: string
    type!: "emptyDir" | "hostPath" | "PVC"
    if type == "hostPath" {
        source!: string
    }
}

#VolumeEphemeral: #Volume & {
    type: "emptyDir"
}

#VolumePersistent: #Volume & {
    type: "PVC"
}

#VolumeBind: #Volume & {
    type: "hostPath"
}
