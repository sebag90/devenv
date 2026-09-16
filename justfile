build_pkgs:
    podman build -t devenv-pkgs:latest -f devenv-pkgs.containerfile .

# use the locally built base: just build PKGS_IMAGE=devenv-pkgs:latest
build PKGS_IMAGE="ghcr.io/sebag90/devenv-pkgs:latest":
    podman build --build-arg PKGS_IMAGE={{PKGS_IMAGE}} -t "devenv:$(date +%d.%m.%Y)_$(uname -m)" -f devenv.containerfile .

build_distro:
    podman build -t ghcr.io/sebag90/sebos:latest -f distro.containerfile .
