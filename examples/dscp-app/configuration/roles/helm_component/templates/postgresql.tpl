apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: {{ name }}-{{ attachment_name }}-postgresql
  namespace: {{ component_ns }}
  annotations:
    fluxcd.io/automated: "false"
spec:
  chart:
    path: {{ charts_dir }}/postgresql
    git: "{{ component_gitops.git_url }}"
    ref: "{{ component_gitops.branch }}"
  releaseName: {{ name }}-{{ attachment_name }}-postgresql
  values:
    global:
      postgresql:
        auth:
          postgresPassword: {{ postgres_password }}
          database: {{ database_name }}
        service:
          ports:
            postgresql: {{ postgres_port }}
