FROM postgres:16
ENV POSTGRES_DB=reviewapp
ENV POSTGRES_USER=reviewuser
ENV POSTGRES_PASSWORD=reviewpass
COPY init.sql /docker-entrypoint-initdb.d/
