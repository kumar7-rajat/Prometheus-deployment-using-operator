## Prometheus Deployment on Kubernetes with Prometheus Operator

A concise, reproducible setup for deploying Prometheus on a Kubernetes cluster (Minikube or any Kubernetes environment), powered by the Prometheus Operator and ServiceMonitor resources.

---

### Table of Contents

1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Deployment Steps](#deployment-steps)

   1. [Create Namespace](#1-create-namespace)
   2. [Deploy Prometheus Operator](#2-deploy-prometheus-operator)
   3. [Deploy Prometheus Custom Resource](#3-deploy-prometheus-custom-resource)
   4. [Expose Prometheus Service](#4-expose-prometheus-service)
   5. [Create ServiceMonitor](#5-create-servicemonitor)
   6. [Access Prometheus UI](#6-access-prometheus-ui)
4. [Label Configuration for Service Discovery](#label-configuration-for-service-discovery)
5. [Validation](#validation)
6. [Cleanup](#cleanup)
7. [License](#license)

---

## Project Overview

This repository demonstrates how to deploy Prometheus using the [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator), which automates:

* Creation of Prometheus StatefulSets and Services
* Dynamic configuration of scrape targets via **ServiceMonitor** custom resources

## Prerequisites

* A running Kubernetes cluster (e.g., [Minikube](https://minikube.sigs.k8s.io/docs/) with the ingress addon enabled).
* `kubectl` installed and configured to target your cluster.
* **Prometheus CRDs** applied:

  ```bash
  kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml
  ```

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

Verify the operator:

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

This step creates a Prometheus StatefulSet and headless Service for internal cluster scraping.

### 4. Expose Prometheus Service

```bash
kubectl apply -f service-prometheus.yml
kubectl apply -f ingress.yml
```

### 5. Create ServiceMonitor

```bash
kubectl apply -f service-monitor.yml
```

The ServiceMonitor tells Prometheus which Services to scrape.

### 6. Access Prometheus UI

* **Via Ingress**: browse to the host/path defined in `ingress.yml`.
* **Minikube CLI**:

  ```bash
  eval "$(minikube service prometheus-server --url -n monitoring)"
  ```

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
    name: prometheus-server  # Must match ServiceMonitor.matchLabels
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
      name: prometheus-server  # Must match Service label
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

# Port-forward and check scrape targets
kubectl port-forward svc/prometheus-server 9090:80 -n monitoring
# Open http://localhost:9090/targets in your browser

# Or use ingress host/path: http://<ingress-host>/target
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

## Images

<img width="1910" height="426" alt="image" src="https://github.com/user-attachments/assets/192d7a07-8846-4375-a5d0-85cb65284eab" />



<img width="1910" height="426" alt="image" src="https://github.com/user-attachments/assets/8d96b78f-7b70-4f27-9312-5ab6bfbd1f75" />


## License

