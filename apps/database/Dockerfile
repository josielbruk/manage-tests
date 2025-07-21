FROM postgres:16
ENV POSTGRES_DB=reviewapp
ENV POSTGRES_USER=reviewuser
COPY init.sql /docker-entrypoint-initdb.d/
