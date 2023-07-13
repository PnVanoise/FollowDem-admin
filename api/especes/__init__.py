from flask import (Blueprint, jsonify, request)
from models import db, Espece
import traceback
import json
from sqlalchemy.exc import IntegrityError
from sqlalchemy import func, desc, asc, or_
from datetime import datetime
from pypnusershub import routes as fnauth


especes = Blueprint('especes', __name__)


@especes.route('/api/especes', methods=['GET'])
def get_especes():
    p_cd_nom = request.args.get("cd_nom")
    # date = request.args.get("date")

    print(p_cd_nom)
    ## query equivaut à un select en sql
    ## filter = where
    query = Espece.query
    if p_cd_nom:
        query = query.filter_by(cd_nom=p_cd_nom)
    
    especes = query.order_by(asc(Espece.nom_vern)).all()
    ## run de la requete
    return jsonify([esp.json() for esp in especes])
