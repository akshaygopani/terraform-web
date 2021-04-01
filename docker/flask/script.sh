#! /bin/bash
python3 -m flask db init
python3 -m flask db migrate
python3 -m flask db upgrade
python3 app.py
#service nginx start
#gunicorn --bind 0.0.0.0:5000 wsgi:app
