#!/usr/bin/python3
import os
from flask import Flask
from flask_cors import CORS


app = Flask(__name__)
cors = CORS(app, supports_credentials=True)
with app.app_context():
    app.config.from_object('conf')

    from models import db
    db.init_app(app)
    import api
    app.register_blueprint(api.api)
    api.init_app(app)

@app.route("/")
def hello():
    return 'hello followDem-server !'

app.run(host='5.196.111.112', port='5000', debug=True)