# Dockerfile pour Flutter Web
# Stage 1: Build Flutter Web App
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy pubspec files and get dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Build the web application
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copier les fichiers build depuis l'étape précédente
COPY --from=build /app/build/web /usr/share/nginx/html

# Copier la configuration Nginx personnalisée
COPY deploy/nginx-docker.conf /etc/nginx/conf.d/default.conf

# Exposer le port 80
EXPOSE 80

# Lancer Nginx
CMD ["nginx", "-g", "daemon off;"]
