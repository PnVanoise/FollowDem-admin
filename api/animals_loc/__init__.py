from flask import (Blueprint, jsonify, request, Flask)
from models import db, AnimalsLoc
import traceback
import json
from sqlalchemy.exc import IntegrityError
from sqlalchemy import func, desc, or_, and_
from geoalchemy2 import func as geo_func
from datetime import datetime, timedelta
from pypnusershub import routes as fnauth

animals_loc = Blueprint('animals_loc', __name__)


@animals_loc.route('/api/animals_loc', methods=['GET'])
def get_animals_loc():
    # nom_vern = request.args.get('nom_vern')
    # attributs = request.args.get('attributs')
    name = request.args.get('name')
    gps_date = request.args.get('gps_date')

    last_day = request.args.get('last_day', 15) # par défaut 15 derniers jours

    d = datetime.today() - timedelta(days=last_day)

    query = db.session.query(AnimalsLoc, func.ST_AsGeoJSON(AnimalsLoc.geom))
    # animals_loc = query.limit(100)
    # animals_loc = query.filter(AnimalsLoc.name == 'Fistule').all()
    # periode = query.filter(or_(AnimalsLoc.gps_date <= current_time - timedelta(last_days)))
    query = query.filter(AnimalsLoc.gps_date >= d) # plusieurs filter à la suite = dans l'url & 
    animals_loc = query.filter(AnimalsLoc.name == name).all() # changer pour id_animal
    # animals_loc = query.filter(AnimalsLoc.name == 'Dario').all()

    features = []

    for item in animals_loc:

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



