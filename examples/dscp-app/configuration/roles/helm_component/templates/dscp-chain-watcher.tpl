apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: {{ name }}-chain-watcher
  namespace: {{ component_ns }}
  annotations:
    fluxcd.io/automated: "false"
spec:
  interval: 1m
  chart:
    spec:
      interval: 1m
      sourceRef:
        kind: GitRepository
        name: flux-{{ network.env.type }}
        namespace: flux-{{ network.env.type }}
      chart: {{ charts_dir }}/dscp-chain-watcher
  releaseName: {{ name }}-chain-watcher
  values:
    fullnameOverride: {{ name }}-chain-watcher
    config:
      dbHost: {{ db_host_addr }}.{{ component_ns }}
      dbPort: {{ peer.postgresql.port }}
      dbUsername: {{ peer.postgresql.user }}
      dbPassword: {{ peer.postgresql.password }}
      dbName: {{ peer.inteli_api.db_name }}
      dscpApiHost: {{ dscp_api_addr }}.{{ component_ns }}
      dscpApiPort: {{ peer.api.port }}
      idServiceHost: {{ peer.name }}-id-service.{{ component_ns }}
      idServicePort: {{ peer.id_service.port }}
      
    image:
      repository: ghcr.io/inteli-poc/dscp-chain-watcher # {"$imagepolicy": "flux-{{ network.env.type }}:dscp-chain-watcher:name"}
      pullPolicy: IfNotPresent
      tag: 'v1.1.0-456ddf7-1667382478' # {"$imagepolicy": "flux-{{ network.env.type }}:dscp-chain-watcher:tag"}
      pullSecrets: 

    vault:
      alpineutils: ghcr.io/hyperledger/alpine-utils:1.0
      address: {{ component_vault.url }}
      secretprefix: {{ component_vault.secret_path | default('secretsv2') }}/data/{{ component_ns }}
      serviceaccountname: vault-auth
      role: vault-role
      authpath: substrate{{ org.name | lower }}
