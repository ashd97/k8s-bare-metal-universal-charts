#  Kubernetes Universal Helm Charts Repository

This repository contains Helm charts optimized for deploying robust and flexible Kubernetes solutions on bare-metal infrastructure. It is designed to handle common challenges associated with traffic ingress, egress, and application deployment, offering seamless integration with modern tools like Istio, Vault, and Filebeat.

##  Charts in This Repository

### 1. Ingress NGINX Helm Chart
Provides a robust ingress proxy for routing intra-namespace traffic.

Key Features:
- WebSocket and security header support.
- Istio compatibility with mutual TLS (mTLS).
- Enhanced logging with request/response tracking.
- Modern TLS 1.2/1.3 support for secure communication.

### 2. Egress NGINX Helm Chart
Handles outbound traffic securely and flexibly.

Key Features:
- Proxy external traffic to services like Vault, PostgreSQL, or third-party APIs.
- Dynamic configuration for multiple protocols.
- Health checks for NGINX monitoring.
- Seamless Istio integration with ServiceEntry and DestinationRule configuration.

### 3. Universal Application Helm Chart
Optimized for deploying Java-based .jar applications, with support for other workloads.

Key Features:
- Istio readiness and mTLS.
- Logging flexibility with Filebeat and Logback.
- HashiCorp Vault integration for secure secret management.
- JVM tuning via $JAVA_OPTS.
- Getting Started

Prerequisites
- Kubernetes 1.18+ on bare-metal infrastructure.
- Helm 3+ and kubectl.

Optional tools:
- Istio for service mesh.
- Vault for secure secrets management.
- Filebeat for log aggregation.

### Recommended Usage Flow
For Istio deployments, start with the egress NGINX chart. Proper outbound traffic configuration ensures that services like Vault and third-party APIs are reachable.


## Contributing
Contributions are welcome! Please fork the repository and submit a pull request with your improvements or bug fixes.

## License
This repository is licensed under the MIT License.

## Keywords
`helm-chart` `kubernetes` `logging` `filebeat` `logback` `egress-proxy` `ingress-proxy` `vault` `istio` `istio-proxy` `devops` `nginx` `java-apps`