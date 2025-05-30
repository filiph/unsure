# Use the official Dart runtime as a parent image
FROM dart:stable AS build

# Set the working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Install dependencies
RUN dart pub get

# Copy the source code
COPY . .

# Compile the application
RUN dart compile exe bin/unsure.dart -o unsure

# Use a minimal base image for the final stage
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the compiled binary from the build stage
COPY --from=build /app/unsure /usr/local/bin/unsure

# Make sure the binary is executable
RUN chmod +x /usr/local/bin/unsure

# Create a non-root user
RUN useradd -m -s /bin/bash unsure

# Switch to the non-root user
USER unsure

# Set the working directory
WORKDIR /home/unsure

# Set the entrypoint
ENTRYPOINT ["unsure"]

# Default command shows help
CMD ["--help"] 