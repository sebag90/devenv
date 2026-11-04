build_pkgs:
    podman build -t pkgs:latest -f pkgs.containerfile .

# use the locally built base: just build PKGS_IMAGE=pkgs:latest
build PKGS_IMAGE="ghcr.io/sebag90/pkgs:latest":
    podman build --build-arg PKGS_IMAGE={{PKGS_IMAGE}} -t "devshell:$(date +%d.%m.%Y)_$(uname -m)" -f devshell.containerfile .

build_distro:
    podman build -t ghcr.io/sebag90/sebos:latest -f distro.containerfile .
