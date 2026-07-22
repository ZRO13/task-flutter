# --- Etapa 1: Construcción (Build) ---
FROM debian:latest AS build-env

# Instalar dependencias necesarias del sistema
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Descargar e instalar el SDK de Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

ENV TAR_OPTIONS="--no-same-owner"
RUN git config --global --add safe.directory /usr/local/flutter
# -----------------------------

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

# Compilar la aplicación para web
# (Si necesitas pasar variables de entorno en la compilación, usa: RUN flutter build web --dart-define=VARIABLE=valor)
RUN flutter build web

# --- Etapa 2: Servidor (Deploy) ---
FROM nginx:alpine

# Eliminar la página por defecto de Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copiar los archivos compilados desde la Etapa 1
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Exponer el puerto 80 para tráfico HTTP
EXPOSE 80

# Iniciar Nginx
CMD ["nginx", "-g", "daemon off;"]
