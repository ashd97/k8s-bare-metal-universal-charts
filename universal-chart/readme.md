# Awesome project-application Helm Chart

This Helm chart **`project-application`** is designed for deploying Java-based `.jar` applications in Kubernetes clusters, but it is flexible enough to support deploying other types of workloads with minor modifications. 

---

## Features
- **Run Any Application**: Although optimized for JAR files, the chart can be customized for other types of applications or services.
- **Istio Ready**: Designed to work seamlessly with Istio service mesh.
- **mTLS and Vault Integration**: Secure application deployments with optional Vault integration and mTLS configuration.
- **Filebeat Integration**: Includes Filebeat for log collection and output (to console or Kafka).
- **Built-in Logging Support**: Choose between console logging, Kafka logging, or ELK-based centralized logging with customizable settings.
- **Configurable Logging**: Supports Logback and Filebeat configurations for customizable log processing.
- **Vault Integration**: Optional integration with HashiCorp Vault for secure secret management.
- **Resource Control**: Fine-grained control over resource limits and requests.
- **Readiness and Liveness Probes**: Ensures applications stay healthy and ready to serve traffic.
- **Environment Variables Configuration**: Supports dynamic injection of environment variables via `values.yaml`, making it adaptable to different environments and requirements.
- **Java-Specific Optimizations**: Automatically leverages `JAVA_OPTS` for JVM tuning.
- **Customizable Probes**: Readiness and liveness probes can be configured for tailored health checks.

---

## Quick Start

### Prerequisites
- Kubernetes 1.18+ cluster
- kubectl 
- Helm 3+
- Optional: HashiCorp Vault for secret management
- Optional: Filebeat and Kafka for logging

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/project-application.git
   cd project-application
   ```

## Environment Variables

The chart allows the configuration of **any number of environment variables** via the `values.yaml` file under the `envVars` section. For example:

```yaml
envVars:
  - name: DEBUG
    value: "true"
  - name: JAVA_OPTS
    value: -Xms256m -Xmx256m --trace
  - name: KAFKA_BOOTSTRAP-SERVERS
    value: "nginx-egress-proxy:9092,nginx-egress-proxy:9093"
  - name: INFO_EXCHANGE_BASE_URL
    value: "http://nginx-egress-proxy:446"
```

2. Customize the `values.yaml` file:
   - Define your Docker image. Update the `projectApp.deployment.image` in `values.yaml` field with your container image.
   - Set environment variables.
   - Adjust resource requests and limits.
   - Modify any other fields as required for your environment (e.g., `ServerPort`, `envVars`).
   - Disable istio and filebeat to be able to just debug an app environment

3. Install the Helm chart, you should be inside k8s folder:
   ```bash
   helm -f values.yaml upgrade --install project-application . --atomic --wait --timeout 600s
   ```

4. Verify the deployment:
   ```bash
   kubectl get events --sort-by='.lastTimestamp'
   ```

5. Get logs of a default container, in another terminal in parallel while installing helm chart, it will parse latest 20 lines of logs:
   ```bash
   kubectl logs $(kubectl get events --sort-by='.lastTimestamp' | tail -20 | grep Started | tail -1 | awk '{ print $4 }') -f
   ```

---

### **Special Support for `$JAVA_OPTS`**

The chart is designed to automatically use `JAVA_OPTS` for JVM tuning. This is injected during container startup via:

```yaml
args:
  - -c
  - printenv; java -XshowSettings:all -version; java -jar *.jar $JAVA_OPTS
```

This makes it easy to set and manage JVM-specific options directly in the `values.yaml` file. You can add or modify environment variables as needed to suit your application requirements.

---

## Chart Structure

- **`values.yaml`**:
  - Define application-specific configurations like image, replicas, environment variables, and logging preferences.
  
- **`_helpers.tpl`**:
  - Templates for generating labels and dynamic values for the chart.
  
- **Logging Configurations**:
  - Filebeat console logging (`filebeat_console.yaml`).
  - Filebeat Kafka integration (`filebeat_kafka.yaml`).
  - Logback configuration (`logback.yaml`).

---

## Configuration

### Key Parameters
| Parameter                         | Description                                        | Default                    |
|-----------------------------------|----------------------------------------------------|----------------------------|
| `projectApp.deployment.image`     | Container image of the application                | `sample-app:latest`        |
| `projectApp.env.ServerPort`       | Application port exposed                          | `8080`                     |
| `projectApp.settings.elkDisabled` | Disables Filebeat/ELK stack integration           | `true`                     |
| `projectApp.settings.logBackLoggerLevel` | Default logback logging level                | `debug`                    |
| `projectApp.vault.agentInitDisabled` | Disables Vault agent sidecar                   | `true`                     |

Refer to the provided `values.yaml` for a comprehensive list of configurable parameters.

### Logging
This chart supports multiple logging outputs:
- **Console Output**: Enabled via `filebeat_console.yaml`.
- **Kafka Output**: Enable Kafka output by setting `filebeatToKafkaDisabled: false` in `values.yaml` and configuring Kafka servers.


### Filebeat Configuration
Filebeat configurations (`filebeat_console.yaml` and `filebeat_kafka.yaml`) are mounted as ConfigMaps. Customize paths, processors, and outputs as needed.

---

## Advanced Usage

### Logback Configuration
Custom Logback configurations are defined in `logback.yaml`. Modify the logging format, appenders, or log levels to suit your application requirements.

### Secrets with Vault
Secure sensitive configurations using HashiCorp Vault:
1. Enable the Vault agent sidecar by setting `vault.agentInitDisabled: false`.
2. Update the Vault role and namespace in the `values.yaml` file.

---

## Example Deployment Configuration
The chart includes the following components:
- **Deployment**: Configurable replicas, resource requests, and limits.
- **Service**: Exposes the application on a configurable port.
- **ConfigMaps**: Includes environment variables and log configuration files.

---

## Folder Structure
- `templates/`: Kubernetes manifests for deployment, services, and ConfigMaps.
- `values.yaml`: Default configuration values.
- `files/`: Logback and Filebeat configuration templates.

---

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any bugs, enhancements, or feature requests.

---

## License
This repository is licensed under [MIT License](LICENSE).

---

## Keywords
`helm-chart` `kubernetes` `logging` `filebeat` `logback` `java-apps` `vault` `istio` `devops`