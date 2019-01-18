apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  namespace: {{.namespace}} 
  name: {{.name}} 
spec:
  serviceName: "{{.name}}"
  podManagementPolicy: Parallel
  replicas: 3
  template:
    metadata:
      labels:
        component: {{.name}}
    spec:
      terminationGracePeriodSeconds: 10
      #initContainers:
       # - name: init 
        #  image: alpine:latest
         # command:
          #  - /bin/sh
           # - -c
           # - "for i in $(seq -s ' ' 1 60); do if getent hosts {{.zoo}}.{{.namespace}}; then exit 0; fi; sleep 1; done; exit 1"
      containers:
        - name: {{.name}}
          image: {{.image}} 
          command: ["/usr/local/bin/entrypoint.sh"]
          env:
            - name: ZOOKEEPER 
              value: "{{.zoo}}"
            - name: DISCOVERY 
              value: {{.discovery}} 
            - name: DATABASE 
              value: {{.database}} 
            - name: POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          volumeMounts:
            - name: host-time
              mountPath: /etc/localtime
              readOnly: true
            - name: runable
              mountPath: /usr/local/bin/entrypoint.sh
              subPath: entrypoint.sh
              readOnly: true
            - name: config
              mountPath: /tmp/server.properties
              subPath: server.properties
              readOnly: true
      volumes:
        - name: host-time
          hostPath:
            path: /etc/localtime
        - name: runable
          configMap:
            name: {{.scripts.cm}} 
            defaultMode: 0755
        - name: config 
          configMap:
            name: {{.conf.cm}} 
