# Build stage
FROM ubuntu:24.04

# Set environment variables for Rust
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    libssl-dev pkg-config \
    ca-certificates && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the full project
COPY . .

# Build the release binary
RUN cargo build --release

# Expose the port (Render will override with $PORT)
EXPOSE 8080

# Run the application, using $PORT from Render
#CMD ["target/release/movie-site-finder", "--port", "$PORT", "-d"]
CMD target/release/movie-site-finder --port $PORT -d
#ENTRYPOINT /bin/sh -c "target/release/movie-site-finder -p ${PORT} -d"
#CMD ["/bin/sh", "-c", "/app/server --port 8080 -d"]


# docker build -t movie-site-finder .
# docker run -p 8080:8080 movie-site-finder
# docker logs <container-id>

##Environment Variables:
# docker run -p 8080:8080 -e KEY=VALUE movie-site-finder