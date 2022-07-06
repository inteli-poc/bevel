apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: {{ name }}-dscp-api
  namespace: {{ component_ns }}
  annotations:
    fluxcd.io/automated: "false"
spec:
  chart:
    path: {{ charts_dir }}/dscp-api
    git: "{{ component_gitops.git_url }}"
    ref: "{{ component_gitops.branch }}"
  releaseName: {{ name }}-dscp-api
  values:
    fullNameOverride: {{ name }}-dscp-api
    config:
      port: {{ peer.api.port }}
      externalNodeHost: "{{ name }}"
      externalNodePort: {{ peer.ws.port }}
      logLevel: info  
      externalIpfsHost: "{{ name }}-ipfs-api" 
      externalIpfsPort: {{ peer.ipfs.apiPort }} 
      enableLivenessProbe: true
      substrateStatusPollPeriodMs: 10000
      substrateStatusTimeoutMs: 2000
      ipfsStatusPollPeriodMs: 10000
      ipfsStatusTimeoutMs: 2000
      auth:
        type: {{ auth_type }} 
        jwksUri: {{ auth_jwksUri }}
        audience: {{ auth_audience }}
        issuer: {{ auth_issuer }}
        tokenUrl: {{ auth_tokenUrl }}
    ingress:
      enabled: false
      className: "gce"
      paths:
        - /v3
    replicaCount: 1
    image:
      repository: ghcr.io/digicatapult/dscp-api
      pullPolicy: IfNotPresent
      tag: 'v4.1.0'
    dscpNode:
      enabled: false

    dscpIpfs:
      enabled: false
      dscpNode:
        enabled: false
    vault:
      alpineutils: ghcr.io/hyperledger/alpine-utils:1.0
      address: {{ component_vault.url }}
      secretprefix: {{ component_vault.secret_path | default('secretsv2') }}/data/{{ component_ns }}/{{ peer.name }}
      serviceaccountname: vault-auth
      role: vault-role
      authpath: substrate{{ org.name | lower }}

    proxy:
      provider: {{ network.env.proxy }}
      name: {{ org.name | lower }} 
      external_url_suffix: {{ org.external_url_suffix }}
      port: {{ peer.api.ambassador }}
      issuedFor: {{ org.name | lower }}
