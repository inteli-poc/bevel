apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: {{ name }}-web
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
      chart: {{ charts_dir }}/dscp-frontend    
  releaseName: {{ name }}-web
  values:
    fullNameOverride: {{ name }}-web
    config:
      port: 80      
      logLevel: info      
      enableLivenessProbe: true
      applicationConfig:
        authDomain: {{ auth_issuer | urlsplit('hostname') }}
        clientID: {{ auth_clientId }}
        authAudience: {{ auth_audience }}
        apiScheme: https
        apiHost: {{ name }}-inteli-api.{{ org.external_url_suffix }}
        apiPort: {{ peer.inteli_api.ambassador }}
        substrateHost: "{{ name }}"
        substratePort: {{ peer.ws.port }}         
        inteliDemoPersona: {{ peer.persona }}
        inteliCustIdentity: {{ cust_peer_id }}
        inteliAmIdentity: {{ am_peer_id }}
        inteliLabIdentity: {{ lab_peer_id }}
        inteliAmlabIdentity: {{ amlab_peer_id | default(lab_peer_id) }}
    ingress: 
      enabled: false
      className: "gce"
      paths:
        - /
    replicaCount: 1
    image:
      repository: ghcr.io/inteli-poc/inteli-demo
      pullPolicy: Always
      tag: 'v3.0.1'

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
      issuedFor: {{ org.name | lower }}
