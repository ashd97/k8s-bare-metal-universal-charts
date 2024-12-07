# Awesome Ingress NGINX Helm Chart

This Helm chart provides a robust and flexible configuration for deploying an NGINX-based ingress proxy within a Kubernetes namespace. It is designed to handle intra-namespace traffic routing and supports integration with Istio for secure, mutual TLS communication, alongside additional features for enhanced observability and logging.

Note: If you want to start tests with Istio in your environment, start it with the nginx-egress-proxy Helm chart. This will create the necessary resources to route outbound traffic (e.g., to Vault or external services). Because without that rules in nginx-egress-proxy helm chart you may not be able to reach services like Vault in this nginx-ingress-proxy or universal chart.

---

## Features

- **Proxying Traffic Within Namespace**: Enables traffic routing across pods within the same namespace.
- **WebSocket Support**: Rich header configurations ensure seamless support for WebSocket connections.
- **Istio Compatibility**: Fully compatible with Istio mutual TLS, integrating seamlessly into service meshes.
- **Enhanced Logging**: Advanced logging setup captures request/response headers, timestamps, and latency details.
- **TLS 1.2 and 1.3 Compatibility**: Supports modern, secure TLS versions for encrypted communication.
---

## Proxying to app services

There is a main config file called `project.conf`, there is a sample redirection sections for site and for common rest-api things.
Just copy this section, and rename needed redirections.

   ```confd nginx config
   # Checks if the 'javaApp1' service is configured in the Java services settings.
   {{ if .Values.projectIngressProxy.settings.javaServices.javaApp1 }}
   
       # Redirect /welcome to /any_long_path/default/ without adding port 8443
       location = /welcome {  # A strict match for the /welcome URL path.
           return 302 https://{{ .Values.projectIngressProxy.tls.proxyDomain }}/any_long_path/default/login_page;  # Redirects the request to the login page without including     the port in the URL.
       }
   
       # Proxy requests under /welcome to the backend service
       location /welcome {  # Defines a location block for the /welcome URL path.
           proxy_pass http://{{ .Values.projectIngressProxy.settings.javaServices.javaApp1 }};  # Proxies the request to the backend Java service.
           proxy_http_version 1.1;  # Uses HTTP/1.1 for the proxied requests.
           include /usr/local/project/nginx/custom/conf/headers.txt;  # Includes the custom headers configuration file for proxy headers.
           ...
       }
   
       location /rest-api/ {  # Defines a location block for the /rest-api/ URL path.
           proxy_pass http://{{ .Values.projectIngressProxy.settings.javaServices.javaApp1 }}/rest-api/;  # Proxies the request to the backend Java service under the /rest-api/     path.
           proxy_http_version 1.1;  # Uses HTTP/1.1 for the proxied requests.
           include /usr/local/project/nginx/custom/conf/headers.txt;  # Includes the custom headers configuration file for proxy headers.
           # proxy_set_header Authorization "Bearer $cookie_JWT";  # Optionally passes a JWT token in the Authorization header.
           proxy_set_header Authorization $http_authorization;  # Passes the original Authorization header to the backend.
           ...
       }
   {{ end }}
   ```

Ingress will check this file at start by nginx -c $NGINX_CONF_PATH -T

---

## TLS 1.2 and 1.3 Support

The chart is configured to support TLS 1.2 and TLS 1.3, providing secure communication for your ingress proxy. This ensures compliance with modern security standards while offering robust encryption for data in transit.

---

## Istio Compatibility

The `DestinationRule` included in the chart enables mutual TLS (mTLS) for Istio environments. Here's how it works:

- **Automatic Mutual TLS**: The `DestinationRule` applies `ISTIO_MUTUAL` mode, ensuring mutual authentication between the client and server using Istio certificates.
- **Port-Level Configuration**: The rule targets port `8080`, where services typically handle REST API traffic.

---

## WebSocket & Security Headers

The `headers.txt` file included in this chart is preconfigured with comprehensive headers to support WebSocket traffic and enhance security. 

### Key Headers in `headers.txt`:

- `Upgrade: websocket`: Enables WebSocket connections by signaling protocol upgrade.
- `Connection: upgrade`: Ensures WebSocket sessions are maintained.
- Security-enhancing headers, such as:
  - `Strict-Transport-Security` for enforcing HTTPS connections.
  - `X-Frame-Options: SAMEORIGIN` to prevent clickjacking.
  - `X-Content-Type-Options: nosniff` to mitigate MIME type sniffing.

These headers make the ingress proxy suitable for real-time applications like chats or streaming services while adhering to modern security practices.

---

## Advanced Logging

This chart includes rich log configuration to enhance observability. Logs capture detailed information such as:

- Request and response headers.
- Request and response body sizes.
- Timestamps for request initiation and completion.
- Total request latency (useful for identifying performance bottlenecks).

You can customize these logs further using your `values.yaml` or by modifying `nginx.conf` directly.

---

## Deployment and Tests

1. Add the default route due to your k8s infrastracture to this nginx-ingress-proxy helm chart, point it to 443 port of nginx-ingress-proxy

1. Install the Helm chart, you should be inside k8s folder:
    ```bash
    helm -f values.yaml upgrade --install nginx-ingress-proxy . --atomic --wait --timeout 600s
    ```

2. Verify the deployment in parallel terminal:
    ```bash
    kubectl get events --sort-by='.lastTimestamp'
    ```

3. Get logs of specific container of nginx-ingress-proxy if something goes wrong in events, using -c flag you can specify a container name:
    ```bash
    kubectl logs <pod-name> -f | tee nginx-ingress-proxy.log
    ```
    Use -c istio-proxy or -c filebeat-elk or -c vault-agent-init
    Or just verify nginx configs that will print container in logs, using nginx -c $NGINX_CONF_PATH -T in deploument.


4.  After you verify nginx configs, try to test ingress from your devops machine host, if publishing NGINX status is enabled - you will get nginx status on this.
    ```bash
    curl -ivvvk https://your-domain.k8s.dmz:443/test
    ```

    Check your certificate
    ```bash
    openssl s_client -showcerts -connect your-domain.k8s.dmz:443  < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | openssl x509 -noout -text
    ```

5. Get into installed ingress pod with bash to check availability of your applications in namespace, use universal-chart to deploy some.
    ```bash
    kubectl exec -it <pod-name> -- bash
    ```
 
    Then use curl to check rest-api itself
    ```bash
    curl -ivvvk http://your-application:8080/rest-api
    ```
 
    Or just check some prometheus metrics
    ```bash
    curl -ivvvk http://your-application:8080/actuator/prometheus
    ```
 
    Check the generated project.conf confing from nginx-ingress-proxy logs to check from nginx bash your proxying and certs
    ```bash
    curl -ivvvk https://nginx-ingress-proxy:443/some-application-service/actuator/prometheus
    ```
 
    Or you can try to check it without service because service forward 443 to 8443
    ```bash
    curl -ivvvk https://127.0.0.1:8443/some-application-service/actuator/prometheus
    ```

---

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any bugs, enhancements, or feature requests.

---

## License
This repository is licensed under [MIT License](LICENSE).

---

## Keywords
`helm-chart` `kubernetes` `logging` `filebeat` `logback` `ingress` `ingress-proxy` `vault` `istio` `istio-proxy` `devops` `nginx`