# Notes for configuring OCPvirt on AWS ROSA

## Configre The Node Placement Rules

### Configure the node placement rules for the virt operator.

Doco here: https://docs.openshift.com/container-platform/4.15/virt/post_installation_configuration/virt-node-placement-virt-components.html#subscription-object-node-placement-rules_virt-node-placement-virt-components

Add this to the subscription object (chenge accorind to the instance type):
```
spec:
  config:
    nodeSelector:
      custom-machine-type: c5n-metal-machinepool
```


### Configure the Host Path Provisioner

```
apiVersion: hostpathprovisioner.kubevirt.io/v1beta1
kind: HostPathProvisioner
  name: hostpath-provisioner
spec:
  imagePullPolicy: IfNotPresent
  storagePools:
    - name: local
      path: /var/hpvolumes
      pvcTemplate:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 60Gi
  workload:
    nodeSelector:
      custom-machine-type: c5n-metal-machinepool
      kubernetes.io/os: linux
```

### Set the Node Placement rules on for the Hyperconverged Operator
```
  infra:
    nodePlacement:
      nodeSelector:
        custom-machine-type: c5n-metal-machinepool
  workloads:
    nodePlacement:
      nodeSelector:
        custom-machine-type: c5n-metal-machinepool
```

This should limit the operator and its components to only run on the bare metal workers:
```$ oc get pods -o wide
NAME                                                              READY   STATUS    RESTARTS      AGE   IP             NODE                                              NOMINATED NODE   READINESS GATES
bridge-marker-bnhcq                                               1/1     Running   0             13m   10.0.133.245   ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
cdi-apiserver-68c577c5-6lw5v                                      1/1     Running   0             17m   10.131.8.63    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
cdi-deployment-f8b5c4dcb-kzj67                                    1/1     Running   0             17m   10.131.8.66    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
cdi-operator-5dc86d9bc6-9rxk5                                     1/1     Running   0             43m   10.131.8.39    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
cdi-uploadproxy-75db5cfdc4-sj8lc                                  1/1     Running   0             17m   10.131.8.65    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
cluster-network-addons-operator-7c78dc8854-jplnr                  2/2     Running   0             43m   10.131.8.36    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
hco-operator-86bcd68b56-m6nhb                                     1/1     Running   0             43m   10.131.8.32    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
hco-webhook-6f4bf4686c-2s2bh                                      1/1     Running   0             43m   10.131.8.33    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
hostpath-provisioner-csi-ts4cb                                    4/4     Running   0             77s   10.131.8.80    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
hostpath-provisioner-operator-5f7fb6495c-xx56w                    1/1     Running   0             43m   10.131.8.40    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
hpp-pool-local-ip-10-0-133-245.ap-southeast-1.compute.interrnr2   1/1     Running   0             77s   10.131.8.81    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
hyperconverged-cluster-cli-download-6cb8d94ff6-6pmlb              1/1     Running   0             43m   10.131.8.34    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
kube-cni-linux-bridge-plugin-zgx6n                                1/1     Running   0             13m   10.131.8.74    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
kubemacpool-cert-manager-7c89cfff74-8f9ss                         1/1     Running   0             17m   10.131.8.64    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
kubemacpool-mac-controller-manager-7c8c4c9489-gpvd9               2/2     Running   0             17m   10.131.8.68    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
kubevirt-console-plugin-569ddcbcfc-t9h6n                          1/1     Running   0             32m   10.131.8.55    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
ssp-operator-5749b6bb5-24cwd                                      1/1     Running   4 (33m ago)   43m   10.131.8.37    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
tekton-tasks-operator-65dc69f589-gtrtl                            1/1     Running   0             43m   10.131.8.38    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
virt-api-58f69d8654-qrgj9                                         1/1     Running   0             12m   10.131.8.76    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
virt-api-58f69d8654-wwmdx                                         1/1     Running   0             13m   10.131.8.73    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
virt-controller-7f59985bc6-vnz2h                                  1/1     Running   0             13m   10.131.8.71    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
virt-controller-7f59985bc6-x5lr7                                  1/1     Running   0             12m   10.131.8.75    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
virt-exportproxy-7b84cb5b68-hddq2                                 1/1     Running   0             13m   10.131.8.72    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
virt-exportproxy-7b84cb5b68-xrmhl                                 1/1     Running   0             12m   10.131.8.77    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
virt-handler-rvrgz                                                1/1     Running   0             13m   10.131.8.69    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
virt-operator-79f59f44c-4bg5f                                     1/1     Running   0             43m   10.131.8.35    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
virt-operator-79f59f44c-dzmdr                                     1/1     Running   0             42m   10.131.8.41    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
virt-template-validator-7dd69799c6-fl92p                          1/1     Running   0             17m   10.131.8.67    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
virt-template-validator-7dd69799c6-r7tdz                          1/1     Running   0             13m   10.131.8.70    ip-10-0-133-245.ap-southeast-1.compute.internal   <none>           <none>
```

## Working VM Configuration

```
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  annotations:
    kubevirt.io/latest-observed-api-version: v1
    kubevirt.io/storage-observed-api-version: v1alpha3
    vm.kubevirt.io/validations: |
      [
        {
          "name": "minimal-required-memory",
          "path": "jsonpath::.spec.domain.resources.requests.memory",
          "rule": "integer",
          "message": "This VM requires more memory.",
          "min": 1073741824
        }
      ]
  resourceVersion: '8902012'
  name: fedora-yappy-hawk
  generation: 1
  namespace: default
  finalizers:
    - kubevirt.io/virtualMachineControllerFinalize
  labels:
    app: fedora-yappy-hawk
    vm.kubevirt.io/template: fedora-server-small
    vm.kubevirt.io/template.namespace: openshift
    vm.kubevirt.io/template.revision: '1'
    vm.kubevirt.io/template.version: v0.25.0
spec:
  dataVolumeTemplates:
    - apiVersion: cdi.kubevirt.io/v1beta1
      kind: DataVolume
      metadata:
        annotations:
          cdi.kubevirt.io/storage.bind.immediate.requested: 'true'
        name: fedora-yappy-hawk
      spec:
        source:
          blank: {}
        storage:
          resources:
            requests:
              storage: 30Gi
    - metadata:
        creationTimestamp: null
        name: fedora-yappy-hawk-installation-cdrom
      spec:
        source:
          http:
            url: >-
              https://download.fedoraproject.org/pub/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2
        storage:
          resources:
            requests:
              storage: 30Gi
  running: false
  template:
    metadata:
      annotations:
        vm.kubevirt.io/flavor: small
        vm.kubevirt.io/os: fedora
        vm.kubevirt.io/workload: server
      creationTimestamp: null
      labels:
        kubevirt.io/domain: fedora-yappy-hawk
        kubevirt.io/size: small
    spec:
      domain:
        cpu:
          cores: 2
          sockets: 1
          threads: 1
        devices:
          disks:
            - bootOrder: 2
              disk:
                bus: virtio
              name: rootdisk
            - bootOrder: 3
              disk:
                bus: virtio
              name: cloudinitdisk
            - bootOrder: 1
              cdrom:
                bus: sata
              name: installation-cdrom
          interfaces:
            - macAddress: '02:83:ac:00:00:01'
              masquerade: {}
              model: virtio
              name: default
          networkInterfaceMultiqueue: true
          rng: {}
        features:
          acpi: {}
          smm:
            enabled: true
        firmware:
          bootloader:
            efi: {}
        machine:
          type: pc-q35-rhel9.2.0
        resources:
          requests:
            memory: 8Gi
      networks:
        - name: default
          pod: {}
      nodeSelector:
        custom-machine-type: c5n-metal-machinepool
      terminationGracePeriodSeconds: 180
      volumes:
        - dataVolume:
            name: fedora-yappy-hawk
          name: rootdisk
        - cloudInitNoCloud:
            userData: |-
              #cloud-config
              user: fedora
              password: m6mu-kuq7-nsn3
              chpasswd: { expire: False }
          name: cloudinitdisk
        - dataVolume:
            name: fedora-yappy-hawk-installation-cdrom
          name: installation-cdrom
```