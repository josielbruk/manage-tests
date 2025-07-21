FROM python:3.12
WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y netcat-openbsd
RUN pip install --no-cache-dir -r requirements.txt
ENV DJANGO_SETTINGS_MODULE=frontend.settings
COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh
CMD ["sh", "-c", "/wait-for-it.sh db 5432 -- bash -c 'python manage.py makemigrations contacts; until python manage.py migrate; do sleep 2; done; python manage.py runserver 0.0.0.0:8000'"]
