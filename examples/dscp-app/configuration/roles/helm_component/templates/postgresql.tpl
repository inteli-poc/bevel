apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: {{ name }}-postgresql
  namespace: {{ component_ns }}
  annotations:
    fluxcd.io/automated: "false"
spec:
  chart:
    path: {{ charts_dir }}/postgresql
    git: "{{ component_gitops.git_url }}"
    ref: "{{ component_gitops.branch }}"
  releaseName: {{ name }}-postgresql
  values:
    image:
      registry: docker.io
      repository: bitnami/postgresql
      tag: 14.4.0
      pullPolicy: IfNotPresent
      debug: false
    global:
      postgresql:
        auth:
          postgresPassword: {{ password }}
          database: {{ first_db_name }}
        service:
          ports:
            postgresql: {{ postgres_port }}
    primary:
      initdb:
        scripts:
          create_second_db.sql: |
            CREATE DATABASE "{{ second_db_name }}";
            GRANT ALL PRIVILEGES ON DATABASE "{{ second_db_name }}" TO {{ username }};
        user: {{ username }}
        password: {{ password }}
