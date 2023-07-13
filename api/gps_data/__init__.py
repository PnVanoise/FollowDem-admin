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
    id_animal = request.args.get('id_animal')
    # id_device = request.args.get('id_device')

    query = Gps_data.query
    # if id_device:
    #     query = query.filter_by(id_device = id_device)
    if id_animal:
        query = query.filter(Gps_data.id_animal==id_animal) ##requete pour filtrer selon le nom de l'animal avec request url ?=
    
    data = query.limit(100)

    return jsonify([move.json() for move in data])
