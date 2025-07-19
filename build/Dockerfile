# This is the source for dbwalker/lua-compiler-devtool
FROM debian:bookworm-slim

# Install required tools
RUN apt-get update && apt-get install -y \
    make \
    lua5.4 \
    lua-sec \
    lua-socket \
    lua-filesystem \
    && rm -rf /var/lib/apt/lists/*

# Set a working directory
WORKDIR /workspace

# Default entrypoint: run shell
ENTRYPOINT ["/bin/sh"]
