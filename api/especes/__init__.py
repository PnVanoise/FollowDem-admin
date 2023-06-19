from flask import (Blueprint, jsonify, request)
from models import db, Espece
import traceback
import json
from sqlalchemy.exc import IntegrityError
from sqlalchemy import func, desc, or_
from datetime import datetime
from pypnusershub import routes as fnauth


especes = Blueprint('especes', __name__)


@especes.route('/api/especes', methods=['GET'])
def get_especes():
    try:
        key = request.args.get("key")
        especes = []
        if key:
            especes = Espece.query. \
                filter(or_(Espece.id_espece.ilike("%" + key + "%"))). \
                order_by(desc(Espece.cd_nom)). \
                all()
        else:
            especes = Espece.query.\
                order_by(desc(Espece.cd_nom)). \
                all()
        return jsonify([espece.json() for espece in especes])
    except Exception:
        traceback.print_exc()
        return jsonify(error='Invalid JSON.'), 400