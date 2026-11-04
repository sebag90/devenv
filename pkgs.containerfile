FROM docker.io/homebrew/brew AS builder

COPY packages.brew ./
RUN xargs brew install -y < packages.brew

FROM fedora AS aggregator

COPY --from=builder /home/linuxbrew/.linuxbrew /home/linuxbrew/.linuxbrew
