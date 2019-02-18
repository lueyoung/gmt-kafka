apiVersion: v1
kind: Service
metadata:
  namespace: default 
  name: kafka-np
spec:
  type: NodePort
  selector:
    #component: kafka
    statefulset.kubernetes.io/pod-name: kafka-0
  ports:
    - port: 9092 
      targetPort: 9092
      nodePort: 19092
      name: cli
