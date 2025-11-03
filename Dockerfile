# Dockerfile pour Flutter Web
FROM nginx:alpine

# Copier les fichiers build dans le répertoire Nginx
COPY build/web /usr/share/nginx/html

# Copier la configuration Nginx personnalisée
COPY deploy/nginx-docker.conf /etc/nginx/conf.d/default.conf

# Exposer le port 80
EXPOSE 80

# Lancer Nginx
CMD ["nginx", "-g", "daemon off;"]
