apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: {{ component_name }}
  namespace: {{ component_ns }}
  annotations:
    flux.weave.works/automated: "false"
spec:
  releaseName: {{ component_name }}
  chart:
    git: {{ git_url }}
    ref: {{ git_branch }}
    path: {{ charts_dir }}/substrate-node

  values:
    image:
      repository: {{ network.docker.url }}/{{ network.config.node_image }}
      tag: {{ network.version }}
      pullPolicy: IfNotPresent
{% if network.docker.password is defined %}
    imagePullSecrets: 
      - name: "regcred"
{% endif %}
    nameOverride: {{ peer.name }}
    fullnameOverride: {{ peer.name }}

    serviceAccount:
      create: false
      name: vault-auth

    podSecurityContext:
      runAsUser: 1000
      runAsGroup: 1000
      fsGroup: 1000
    ingress:
      enabled: false

    node:
      name: {{ peer.name }}
      namespace: {{ component_ns }}
      chain: inteli-gcp
      command: {{ command }}      
      dataVolumeSize: 10Gi
      replicas: 1
      role: {{ role }}
      customChainspecUrl: true
      customChainspecPath: "/data/chainspec.json"
      collator:
        isParachain: false
                
      enableStartupProbe: false
      enableReadinessProbe: false
      flags:
        - "--rpc-external"
        - "--ws-external"
        - "--rpc-methods=Unsafe"
        - "--rpc-cors=all"
        - "--unsafe-ws-external"
        - "--unsafe-rpc-external"
{% if bootnode_data is defined %}
        - "--bootnodes '{{ bootnode_data[1:] | join(',') }}'"
{% endif %}
      keys:
        - type: "gran"
          scheme: "ed25519"
          seed: "grandpa_seed"
        - type: "aura"
          scheme: "sr25519"
          seed: "aura_seed"
      persistGeneratedNodeKey: false
      
      resources: {}
      serviceMonitor:
        enabled: false
        
      perNodeServices:
        createClusterIPService: true
        createP2pNodePortService: true
        p2pServiceType: ClusterIP
        setPublicAddressToExternalIp:
          enabled: false
          ipRetrievalServiceUrl: https://ifconfig.io
      podManagementPolicy: Parallel

      ports:
        p2p: {{ peer.p2p.port }}
        ws: {{ peer.ws.port }}
        rpc: {{ peer.rpc.port }}

      tracing:
        enabled: false
      substrateApiSidecar:
        enabled: false

    proxy:
      provider: ambassador
      external_url: {{ peer.name }}.{{ external_url }}
      p2p: {{ peer.p2p.ambassador }}

    storageClass: {{ storageclass_name }}

    vault:
      address: {{ vault.url }}      
      secretPrefix: {{ vault.secret_path | default('secretsv2') }}/data/{{ component_ns }}
      authPath: substrate{{ name }}
      appRole: vault-role
      image: {{ network.docker.url }}/hyperledger/alpine-utils:1.0 
