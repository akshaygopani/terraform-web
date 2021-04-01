FROM python:3.8.5

EXPOSE 5000

ENV APP_DIR /app

ENV APP_USER flask

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV MYSQL_USER="flask"
ENV MYSQL_PASSWORD="crudflask987"
ENV MYSQL_DATABASE="crud"
ENV APP_PORT=80  
ENV DATABASE_IP="localhost"
ENV DATABASE_PORT=3306 
ENV DATABASE_URL="mysql+pymysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${DATABASE_IP}:${DATABASE_PORT}/${MYSQL_DATABASE}"

RUN addgroup --system $APP_USER  && adduser --system --group $APP_USER
RUN mkdir -p $APP_DIR

RUN apt-get update -y
RUN apt-get install -y vim \
                   wget \
                   dialog \
                   net-tools 
# RUN apt-get install -y nginx

# RUN rm /etc/nginx/nginx.conf
# COPY nginx.conf /etc/nginx/
# COPY flask-nginx.conf  /etc/nginx/conf.d/
# RUN  rm /etc/nginx/sites-enabled/default
# RUN  rm /etc/nginx/sites-available/default 
# RUN  rm -r /var/www/html
RUN pip install --upgrade pip

WORKDIR $APP_DIR
COPY ./flask $APP_DIR

RUN pip install -r requirements.txt

#RUN gunicorn --bind 0.0.0.0:5000 wsgi:app
CMD ["/bin/bash","script.sh"]
