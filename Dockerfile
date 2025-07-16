# Build stage
FROM rust:1.83.0-bookworm AS builder

# Set working directory
WORKDIR /app

# Copy dependency files first for caching
COPY Cargo.toml Cargo.lock ./

# Create a dummy main.rs to cache dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs && cargo build --release && rm -rf src

# Copy the full project
COPY . .

# Build the release binary
RUN cargo build --release

# Final stage
FROM gcr.io/distroless/cc-debian12

# Copy the binary from the builder stage
COPY --from=builder /app/target/release/movie-site-finder /app/server

# Expose the port (Render will override with $PORT)
EXPOSE 8080

# Run the application, using $PORT from Render
CMD ["/app/server", "--port", "${PORT}", "-d"]