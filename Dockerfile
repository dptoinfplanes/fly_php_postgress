FROM php:8.2-apache

# 1. Instalar dependencias de Postgres
RUN apt-get update && apt-get install -y \
    libpq-dev \
    postgresql-client \
    && docker-php-ext-install pdo pdo_pgsql pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Definir la variable de entorno directamente aquí
# Sustituimos los Secrets de Fly.io por esta línea:
ENV DATABASE_URL="postgresql://fly-user:tPZ1lHoJxuKM7vHh3KbEB9Xh@pgbouncer.z23750v7myl096d1.flympg.net/fly-db"

# 3. Configurar Apache para Fly.io (Puerto 8080)
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf

# 4. Configurar el DocumentRoot para que apunte a /src
ENV APACHE_DOCUMENT_ROOT /var/www/html/src
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 5. Copiar todo el proyecto
COPY . /var/www/html/

# 6. Script de entrada
RUN echo '#!/bin/bash\n\
echo "Ejecutando script SQL inicial usando la URL directa..."\n\
psql "$DATABASE_URL" -f /var/www/html/sql/init.sql\n\
apache2-foreground' > /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8080

CMD ["/usr/local/bin/docker-entrypoint.sh"]
