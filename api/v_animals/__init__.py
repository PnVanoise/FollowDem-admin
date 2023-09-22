from flask import (Blueprint, jsonify, request, Flask)
from models import db, V_Animals
import traceback
import json
from sqlalchemy.exc import IntegrityError
from sqlalchemy import func, desc, asc, or_, and_
from datetime import datetime
from pypnusershub import routes as fnauth

v_animals = Blueprint('v_animals', __name__)

@v_animals.route('/api/v_animals', methods=['GET'])
def get_v_animals():

    query = V_Animals.query
    
    v_animals = query.all()

    for item in v_animals:
        # Créer un dictionnaire pour stocker les attributs
        attributes = {}
        if item.attributs is not None:
            for attr in item.attributs:
                if attr is not None:
                    # Diviser la chaîne d'attribut en clé et valeur
                    key_value = attr.split(':')
                    if len(key_value) == 2:
                        key, value = key_value
                        # Ajouter l'attribut au dictionnaire
                        attributes[key] = value
        # Remplacer la liste d'attributs par le dictionnaire d'attributs
        item.attributs = attributes

    # Convertir les données modifiées en JSON
    modified_v_animals = jsonify([anicol.json() for anicol in v_animals])

    return modified_v_animals