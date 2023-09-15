from flask import (Blueprint, jsonify, request, Flask)
from models import db, V_AnimalsLoc
import traceback
import json
from sqlalchemy.exc import IntegrityError
from sqlalchemy import func, desc, asc, or_, and_
from geoalchemy2 import func as geo_func
from datetime import datetime, timedelta
from pypnusershub import routes as fnauth

v_animals_loc = Blueprint('v_animals_loc', __name__)


@v_animals_loc.route('/api/v_animals_loc', methods=['GET'])
def get_v_animals_loc():

    name = request.args.get('name')
    # last_day = int(request.args.get('last_day', 15)) # par défaut 15 derniers jours
    last_day = request.args.get('last_day')

    query = db.session.query(V_AnimalsLoc, func.ST_AsGeoJSON(V_AnimalsLoc.geom))

    if name:
        query = query.filter(V_AnimalsLoc.name == name)
    if last_day:
        last_day = int(last_day)
        end_date = datetime.today()
        start_date = end_date - timedelta(days=last_day)
        query = query.filter(
            V_AnimalsLoc.gps_date >= start_date,
            V_AnimalsLoc.gps_date <= end_date
        )
    v_animals_loc = query.all()

    features = []

    for item in v_animals_loc:

        attributes = {}
        if item[0].attributs is not None:
            for attr in item[0].attributs:
                if attr is not None:
                    key_value = attr.split(':')
                    if len(key_value) == 2:
                        key, value = key_value
                        attributes[key] = value
        item[0].attributs = attributes
        
        # print(type(item[0].gps_date))
        
        
        feature = {
            'type': 'Feature',
            'geometry': json.loads(item[1]),
            'properties': item[0].json()
        }
        features.append(feature)
        
    feature_collection = {
        'type': 'FeatureCollection',
        'features': features
        }
    
    return jsonify(feature_collection)



