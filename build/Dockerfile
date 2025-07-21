# This is the source for dbwalker/lua-compiler-devtool
FROM debian:bookworm-slim

# Install required tools
RUN apt-get update && apt-get install -y \
    make \
    lua5.4 \
    lua-sec \
    lua-socket \
    lua-filesystem \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Set a working directory
WORKDIR /workspace

