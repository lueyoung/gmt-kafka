apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    {{.labels.key}}: {{.labels.value}}
  name: {{.service.account}}
  namespace: {{.namespace}}
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: {{.service.account}}-in-{{.namespace}}
subjects:
  - kind: ServiceAccount
    name: {{.service.account}}
    namespace: {{.namespace}}
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
