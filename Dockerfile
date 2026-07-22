# --- Etapa 1: Construcción (Build) ---
FROM debian:latest AS build-env

# Instalar dependencias necesarias del sistema
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Descargar e instalar el SDK de Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

ENV TAR_OPTIONS="--no-same-owner"
RUN git config --global --add safe.directory /usr/local/flutter

# Configurar Flutter para web
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar el código fuente de tu proyecto al contenedor
COPY . .

# Descargar las dependencias
RUN flutter pub get

# --- INYECCIÓN DE VARIABLES DE RENDER ---
# 1. Declarar las variables que Render inyectará durante el build
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_ANON_KEY
ARG GOOGLE_CLIENT_ID

# 2. Compilar inyectando esas variables al código de Flutter
RUN flutter build web \
    --dart-define=VITE_SUPABASE_URL=$VITE_SUPABASE_URL \
    --dart-define=VITE_SUPABASE_ANON_KEY=$VITE_SUPABASE_ANON_KEY \
    --dart-define=GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID

# --- Etapa 2: Servidor (Deploy) ---
FROM nginx:alpine

# Eliminar la página por defecto de Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copiar los archivos compilados desde la Etapa 1
COPY --from=build-env /app/build/web /usr/share/nginx/html

# --- CONFIGURACIÓN PARA FLUTTER WEB (SPA) ---
# Le decimos a Nginx que devuelva index.html para cualquier ruta (ej. /login) para evitar el error 404
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Exponer el puerto 80 para tráfico HTTP
EXPOSE 80

# Iniciar Nginx
CMD ["nginx", "-g", "daemon off;"]
