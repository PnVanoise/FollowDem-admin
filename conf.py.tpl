from models import (db)
SERVER_NAME = '127.0.0.1:5000'
SQLALCHEMY_DATABASE_URI = 'postgres://<user>:<passwd>@<host>:<port>/<database>'
SQLALCHEMY_TRACK_MODIFICATIONS = False
DB=db
PASS_METHOD = 'md5'
COOKIE_EXPIRATION=3600
SECRET_KEY='fls32'
