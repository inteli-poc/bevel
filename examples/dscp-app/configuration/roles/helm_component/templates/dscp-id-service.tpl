apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: {{ name }}-id-service
  namespace: {{ component_ns }}
  annotations:
    fluxcd.io/automated: "false"
spec:
  chart:
    path: {{ charts_dir }}/dscp-identity-service
    git: "{{ component_gitops.git_url }}"
    ref: "{{ component_gitops.branch }}"
  releaseName: {{ name }}-id-service
  values:
    fullNameOverride: {{ name }}-id-service
    config:
      externalNodeHost: {{ name }}
      externalPostgresql: {{ db_address }}.{{ component_ns }}
      port: {{ peer.id_service.port }}
      logLevel: info
      dbName: {{ peer.id_service.db_name }}
      dbPort: {{ peer.postgresql.port }}
      enableLivenessProbe: true
      selfAddress: 
      auth:
        type: {{ auth_type }}
        jwksUri: {{ auth_jwksUri }}
        audience: {{ auth_audience }}
        issuer: {{ auth_issuer }}
        tokenUrl: {{ auth_tokenUrl }}
    ingress:
      enabled: false
      # annotations: {}
      # className
      paths:
        - /v1/members
    replicaCount: 1
    image:
      repository: ghcr.io/digicatapult/dscp-identity-service
      pullPolicy: IfNotPresent
      tag: 'v1.6.0'
      pullSecrets: 

    postgresql:
      enabled: false
      postgresqlDatabase: {{ peer.id_service.db_name }}
      postgresqlUsername: {{ peer.postgresql.user }}
      postgresqlPassword: {{ peer.postgresql.password }}
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
      port: {{ peer.id_service.ambassador }}
      issuedFor: {{ org.name | lower }}
