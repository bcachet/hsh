Traefik serves as a reverse proxy to expose containerized services 
(running on Podman) to the internet with automatic HTTPS certificates.

- Traefik listens on ports 80 and 443
- Traefik connects to Podman socket to detect containers launched with Traefik labels
- Automatic HTTPS: Uses Let's Encrypt to generate SSL certificates 
  (stored in traefik-acme Podman volume)
- HTTP → HTTPS redirect: All HTTP traffic is redirected to HTTPS

Services use Traefik labels to configure routing.
