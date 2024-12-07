# Awesome Egress NGINX Helm Chart

This Helm chart deploys an NGINX proxy for handling egress traffic from a Kubernetes namespace to external services. It allows you to proxy outbound traffic securely, manage connection configurations, and enforce security policies. The chart includes configuration for multiple protocols (such as HTTP, HTTPS, and more) and integrates with Istio for advanced routing features.

## Overview

The **Egress NGINX Helm Chart** is designed to proxy traffic from your Kubernetes namespace to external systems, such as databases, APIs, and third-party services. It can handle traffic for multiple services, including Kafka, PostgreSQL, and custom services like Keycloak, InfoExchange, etc.

The chart also provides seamless integration with Istio, which simplifies the management of service entries and destination rules for external traffic routing.

If you need istio, you should start with this nginx-egress-proxy.

## Features

- **Proxy External Traffic**: Forward traffic from your Kubernetes pods to external services.
- **Dynamic Service Configuration**: Define specific ports and protocols for external services.
- **Istio Integration**: Automatically configures Istio service entries and destination rules for managing external service routes.
- **Health Checks**: Configurable liveness and readiness probes to monitor NGINX proxy status.
- **SSL/TLS Support**: Enable SSL/TLS for secure communication to external services.
- **Customizable Resources**: Configure CPU, memory, and other resource limits for NGINX and Filebeat containers.
- **Advanced Logging**: Integrates with ELK for log collection and monitoring.
- **Vault integration**: Ready to use vault.hashicorp.com settings in deployment for mounting certificates from Vault.

## Configuration

The chart provides flexible configuration options via `values.yaml` file, allowing customization of various parameters including NGINX settings, Istio configurations, and logging options.

### Key Configuration Options

#### 1. **NGINX General Settings**

The Helm chart deploys an NGINX container that proxies traffic to external services. Key configuration options include:

- **Affinity**: Ensures the proxy is scheduled on specific nodes, avoiding unnecessary pod placement across different nodes.
- **Volumes**: Configures the required NGINX configuration files (`nginx.conf`, `status.conf`, etc.) and SSL certificates.
- **Service Account**: Defines the Kubernetes service account to be used by the egress proxy.
- **Resource Requests and Limits**: Set limits for CPU and memory usage for the NGINX container.
- **Health Probes**: Configurable liveness and readiness probes to monitor the health of the NGINX container.

---

#### 2. **NGINX proxying of rest-api endpoints**

File info-exchange.conf shows how to proxy using 8446 port to endpoint specified in values in infoExchange section.

If you need to add additional rest-api endpoint:
- Just create another a copy of sample file info-exchange.conf, specify another port - 8447 for exaple.
- Add that port in service.yaml file, for example 447 port to 8447 internal port.
- Modify the info-exchange-destination-rule.yaml + info-exchange-service-entry.yaml file with same thing as 446 port rule.

---

#### 3. **Istio Integration**

When Istio is enabled, the chart automatically configures Istio service entries and destination rules for routing external traffic. This is useful for managing external service routing within the Istio service mesh.

- ServiceEntry Configuration: The chart creates ServiceEntry resources to define external services.
- DestinationRule: Ensures that NGINX can route traffic securely to external services, such as Keycloak, or any rest-api endpoints.

For services like Kafka and PostgreSQL, there is no need to create a DestinationRule and ServiceEntry, as they are typically handled using direct TCP configurations without requiring Istio's service routing. The ServiceEntry and DestinationRule files in the configuration above focus on other external services like any InfoExchange, Keycloak, and similar HTTP/HTTPS-based services, while Kafka and PostgreSQL can bypass this configuration.

---

#### 4. **Filebeat and Log Collection**

The chart can also integrate with Filebeat for forwarding logs from the egress proxy to an external ELK stack. Filebeat is configured to collect logs from the NGINX container and forward them for centralized logging and monitoring.

There is 3 tested Filebeat Configuration files

- filebeat.yml for console output
- filebeat_elk.yml for output to logstash (beats port)
- filebeat_kafka.yml for sending logs directly to kafka topics

---

#### 5. **Deployment and Usage**

1. Install the Helm chart, you should be inside k8s folder:
   ```bash
   helm -f values.yaml upgrade --install nginx-egress-proxy . --atomic --wait --timeout 600s
   ```

2. Verify the deployment in parallel terminal:
   ```bash
   kubectl get events --sort-by='.lastTimestamp'
   ```

3. Get logs of specific container if something goes wrong in events, using -c flag you can specify a container name:
   ```bash
   kubectl logs <pod-name> -f | tee nginx-egress-proxy.log
   ```
   -c istio-proxy or -c filebeat-elk or -c vault-agent-init

4. Get into installed egress pod with bash to check availability of external endpoints 
   ```bash
   kubectl exec -it <pod-name> -- bash
   ```

   Then use curl to check certs etc

   ```bash
   curl -ivvvk https://info-exchange-endpoint.dmz
   ```

---

#### 6. **Testing nginx-egress-proxy**

   Deploy for any other helm chart, nginx-ingress-proxy or some app with universal-chart

1. Get into any other container in bash on another pod:
   ```bash
   kubectl exec -it <pod-name> -- bash
   ```
2. Using curl check your certs and redirections from your rest-api endpoint:
   ```bash
   curl -ivvvk https://nginx-egress-proxy:446/
   ```

---

#### 7. **How to check istio and how to debug istio-proxy**

   If you are getting issues when enabling istio using "istioDisabled: false", check this:
   - verify istio revision in your k8s, in deployment its configured: istio.io/rev: '1-0-0'
   - enbale istio sidecar debug logs
   - get into the installed egress pod with bash and call curl command like above
   
   Enable debug logs of istio-proxy
   ```bash
   kubectl exec -it <pod-name> -c istio-proxy -- curl -X POST "http://localhost:15000/logging?level=debug"
   ```

   Log in nginx in bash
   ```bash
   kubectl exec -it <pod-name> -- bash
   ```

   Then use curl to check something you need
   ```bash
   curl -ivvvk https://info-exchange-endpoint.dmz
   ```

   Then check logs
   ```bash
   kubectl logs <pod-name> -c istio-proxy -f | tee nginx-egress-proxy-istio-proxy.log
   ```

   The lines like `tls inspector: new connection accepted` indicate that the TLS Inspector filter in Envoy (which Istio uses as its sidecar proxy) is recognizing new connections and ensuring that the appropriate security measures are in place.
   
---

The Egress NGINX Helm Chart is a powerful tool for routing external traffic from a Kubernetes cluster while ensuring security and flexibility. With the ability to integrate with Istio, configure logging, and support custom services, it offers a comprehensive solution for managing outbound traffic in your Kubernetes environment.

For more information, check the Istio Documentation and NGINX Documentation.

This `README.md` provides detailed documentation for deploying and managing the Egress NGINX Helm chart, integrating Istio, logging with Filebeat, and handling various external services. It is organized clearly, with sections for configuration, usage, and troubleshooting, designed for users to easily understand and follow the steps for successful deployment and management.

---

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any bugs, enhancements, or feature requests.

---

## License
This repository is licensed under [MIT License](LICENSE).

---

## Keywords
`helm-chart` `kubernetes` `logging` `filebeat` `logback` `egress-proxy` `vault` `istio` `istio-proxy` `devops` `nginx`