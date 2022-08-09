apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: {{ name }}-chain-watcher
  namespace: {{ component_ns }}
  annotations:
    fluxcd.io/automated: "false"
spec:
  chart:
    path: {{ charts_dir }}/dscp-chain-watcher
    git: "{{ component_gitops.git_url }}"
    ref: "{{ component_gitops.branch }}"
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
      
    image:
      repository: ghcr.io/inteli-poc/dscp-chain-watcher
      pullPolicy: IfNotPresent
      tag: 'v1.0.1'
      pullSecrets: 
