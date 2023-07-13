from flask import (Blueprint, jsonify, request, Flask)
from models import db, AnimalsColor
import traceback
import json
from sqlalchemy.exc import IntegrityError
from sqlalchemy import func, desc, asc, or_, and_
from datetime import datetime
from pypnusershub import routes as fnauth

animals_color = Blueprint('animals_color', __name__)

@animals_color.route('/api/animals_color', methods=['GET'])
def get_animals_color():

    query = AnimalsColor.query
    
    animals_color = query.order_by(asc(AnimalsColor.name)).all()

    for item in animals_color:
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
    modified_animals_color = jsonify([anicol.json() for anicol in animals_color])

    # return jsonify([anicol.json() for anicol in animals_color])
    return modified_animals_color