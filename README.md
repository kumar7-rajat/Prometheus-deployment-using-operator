## Prometheus Deployment on Kubernetes with Prometheus Operator

This repository contains YAML manifests and instructions to deploy Prometheus on a Kubernetes cluster using the Prometheus Operator. It provides a straightforward, reproducible setup for a Prometheus instance on Minikube (or any Kubernetes environment). Prometheus Operator updated configuration dynamically by using the concept of Service Monitor.

---

### Table of Contents

* [Project Overview](#project-overview)
* [Prerequisites](#prerequisites)
* [Deployment Steps](#deployment-steps)

  * [1. Create Namespace](#1-create-namespace)
  * [2. Deploy Prometheus Operator](#2-deploy-prometheus-operator)
  * [3. Deploy Prometheus Custom Resource](#3-deploy-prometheus-custom-resource)
  * [4. Expose Prometheus Service](#4-expose-prometheus-service)
  * [5. Create ServiceMonitor](#5-create-servicemonitor)
  * [6. Access Prometheus UI](#6-access-prometheus-ui)
* [Label Configuration for Service Discovery](#label-configuration-for-service-discovery)
* [Validation](#validation)
* [Cleanup](#cleanup)
* [License](#license)

---

## Project Overview

This setup uses the [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator) to manage Prometheus instances in Kubernetes. The operator automates creation of StatefulSets and Services for Prometheus resources and integrates ServiceMonitor objects for scraping metrics.

## Prerequisites

* A running Kubernetes cluster (e.g., [Minikube](https://minikube.sigs.k8s.io/docs/) with ingress addon).
* `kubectl` configured to communicate with your cluster.
* Install mandatories CRDs using below link:

## Deployment Steps

### 1. Create Namespace

```bash
kubectl apply -f namespace.yml
```

### 2. Deploy Prometheus Operator

```bash
kubectl apply -f service-account-operator.yml
kubectl apply -f role-operator.yml
kubectl apply -f rolebinding-operator.yml
kubectl apply -f prometheus-operator.yml
```

Verify operator status:

```bash
kubectl get pods,svc,deploy -n monitoring
```

### 3. Deploy Prometheus Custom Resource

```bash
kubectl apply -f service-account-prometheus.yml
kubectl apply -f role-prometheus.yml
kubectl apply -f rolebinding-prometheus.yml
kubectl apply -f prometheus.yml
```

This creates a Prometheus StatefulSet and headless service.

### 4. Expose Prometheus Service

```bash
kubectl apply -f service-prometheus.yml
kubectl apply -f ingress.yml
```

### 5. Create ServiceMonitor

```bash
kubectl apply -f service-monitor.yml
```

### 6. Access Prometheus UI

* **Ingress:** Navigate to the host/path configured in `ingress.yml`.

---

## Label Configuration for Service Discovery

Ensure your Service has matching labels so that the ServiceMonitor selector can discover it:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: prometheus-server
  namespace: monitoring
  labels:
    name: prometheus-server  # Service labels that will be used by Service Monitor
spec:
  selector:
    name: prometheus-server
  ports:
    - name: webs
      port: 80
      targetPort: 9090
  type: ClusterIP
```

The ServiceMonitor (`service-monitor.yml`) uses:

```yaml
spec:
  selector:
    matchLabels:
      name: prometheus-server  # Service label that is defined in the service .metadata.labels
  endpoints:
    - port: webs
      path: /metrics
      interval: 30s
```

Apply or re-apply the Service to activate discovery:

```bash
kubectl apply -f service-prometheus.yml
```

---

## Validation

```bash
# List ServiceMonitors
kubectl get servicemonitor -n monitoring

# Port-forward to Prometheus and view targets
kubectl port-forward svc/prometheus-server 9090:80 -n monitoring
# Or open host that is defined in the ingress: http://<ingress-host>/target
```

---

## Cleanup

```bash
kubectl delete -f ingress.yml
kubectl delete -f service-prometheus.yml
kubectl delete -f service-monitor.yml
kubectl delete -f prometheus.yml
kubectl delete -f rolebinding-prometheus.yml
kubectl delete -f role-prometheus.yml
kubectl delete -f service-account-prometheus.yml
kubectl delete -f prometheus-operator.yml
kubectl delete -f rolebinding-operator.yml
kubectl delete -f role-operator.yml
kubectl delete -f service-account-operator.yml
kubectl delete -f namespace.yml
```

---

## License

