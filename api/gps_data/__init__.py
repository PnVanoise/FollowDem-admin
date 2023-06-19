from flask import (Blueprint, jsonify, request)
from models import db, Gps_data
import traceback
import json
from sqlalchemy.exc import IntegrityError
from sqlalchemy import func, desc, or_
from datetime import datetime
from pypnusershub import routes as fnauth


gps_data = Blueprint('gps_data', __name__)


@gps_data.route('/api/gps_data', methods=['GET'])
def get_gps_data():
    try:
        key = request.args.get("key")
        gps_data = []
        if key:
            gps_data = Gps_data.query. \
                filter(or_(Gps_data.id_gps_data.ilike("%" + key + "%"))). \
                order_by(desc(Gps_data.gps_date)). \
                all()
        else:
            gps_data = Gps_data.query.\
                order_by(desc(Gps_data.gps_date)). \
                all()
        return jsonify([move.json() for move in gps_data])
    except Exception:
        traceback.print_exc()
        return jsonify(error='Invalid JSON.'), 400