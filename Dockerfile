# Build stage
FROM rust:1.83.0-bookworm AS build

# Set working directory
WORKDIR /app

# Copy the full project
COPY . .

# Build the release binary
RUN cargo build --release

# Final stage
FROM gcr.io/distroless/cc-debian12

# Copy the binary from the builder stage
COPY --from=build /app/target/release/movie-site-finder /app/server

# Expose the port (Render will override with $PORT)
EXPOSE 8080

# Run the application, using $PORT from Render
CMD ["/app/server", "--port", "${PORT}", "-d"]