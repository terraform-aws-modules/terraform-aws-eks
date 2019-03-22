# Definition of ENIConfig for zone: ${zone}
---
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: ${zone}
spec:
  subnet: ${subnet}
  securityGroups:
${security_groups}