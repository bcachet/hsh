# Development worklflow

```sh
# 0. Setup environment
# Tooling has been installed via [Mise](https://mise.jdx.dev/)
mise install
mise activate
# 1. Make changes
# 2. Typecheck
#!/usr/bin/fish
for DIR in ./schemas ./workloads
    cue vet -c $DIR
end
# 3. Run tests
cue cmd compose | tee docker-compose.yml && podman-compose up -d
docker-compose down -v

# 4. Lint
# cue cmd lint

```
