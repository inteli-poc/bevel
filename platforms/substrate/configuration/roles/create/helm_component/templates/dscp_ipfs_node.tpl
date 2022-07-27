apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: {{ component_name }}
  namespace: {{ component_ns }}
  annotations:
    fluxcd.io/automated: "false"
spec:
  releaseName: {{ component_name }}
  chart:
    git: {{ org.gitops.git_url }}
    ref: {{ org.gitops.branch }}
    path: {{ charts_dir }}/dscp-ipfs-node
  values:
    fullnameOverride: {{ peer.name }}-ipfs
    config:
      healthCheckPort: 80
      healthCheckPollPeriod: 30000
      healthCheckTimeout: 2000
      nodeHost: "{{ peer.name }}"
      nodePort: "{{ peer.ws.port }}"
      logLevel: info
      ipfsApiPort: {{ peer.ipfs.apiPort }}
      ipfsSwarmPort: {{ peer.ipfs.swarmPort }}
      ipfsDataPath: "/ipfs"
      ipfsCommand: "/usr/local/bin/ipfs"
      ipfsArgs:
        - daemon
        - "--migrate"
      ipfsSwarmAddrFilters: null
      ipfsLogLevel: info
{% if ipfs_bootnode is defined %}
      ipfsBootNodeAddress: {{ ipfs_bootnode[1:] | join(',') }}
{% endif %}      
    service:
      swarm:
        annotations: {}
        enabled: true
        port: {{ peer.ipfs.swarmPort }}
      api:
        annotations: {}
        enabled: true
        port: {{ peer.ipfs.apiPort }}

    statefulSet:
      annotations: {}
      livenessProbe:
        enabled: true
    image:
      repository: {{ docker_url }}/digicatapult/dscp-ipfs
      pullPolicy: IfNotPresent
      tag: 'v2.6.1'
    storage:
      storageClass: "{{ storageclass_name }}"
      dataVolumeSize: 20  # in Gigabytes
    dscpNode:
      enabled: false
    proxy:
      provider: ambassador
      external_url: {{ peer.name }}-ipfs-swarm.{{ external_url }}
      port: {{ peer.ipfs.ambassador }}
      certSecret: {{ org.name | lower }}-ambassador-certs
    vault:
      address: {{ vault.url }}
      role: vault-role
      authpath: substrate{{ name }}
      serviceaccountname: vault-auth
      certsecretprefix: {{ vault.secret_path | default('secretsv2') }}/data/{{ component_ns }}/{{ peer.name }}
