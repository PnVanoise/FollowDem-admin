#!/bin/bash

. settings.ini

function database_exists () {
    # /!\ Will return false if psql can't list database. Edit your pg_hba.conf as appropriate.
    if [ -z $1 ]
        then
        # Argument is null
        return 0
    else
        # Grep db name in the list of database
        sudo -n -u postgres -s -- psql -tAl | grep -q "^$1|"
        return $?
    fi
}

# Suppression du fichier de log d'installation si il existe déjà puis création de ce fichier vide.
rm  -f ../var/log/install_db.log
mkdir -p ../var/log/
touch ../var/log/install_db.log

# Si la BDD existe, je verifie le parametre qui indique si je dois la supprimer ou non

if database_exists $db_name
    then
        if $drop_apps_db
            then
            echo "Suppression de la BDD..."
            sudo -n -u postgres -s dropdb $db_name  &>> ../var/log/install_db.log
        else
            echo "La base de données existe et le fichier de settings indique de ne pas la supprimer."
        fi
fi

# Sinon je créé la BDD
if ! database_exists $db_name
then

	echo "Création de la BDD..."
    sudo -u postgres psql -c "CREATE USER $owner_followdem WITH PASSWORD '$owner_followdem_pass' "  &>> ../var/log/install_db.log
    sudo -n -u postgres -s createdb  $db_name
    sudo -n -u postgres -s psql -c "ALTER DATABASE $db_name OWNER TO $owner_followdem ;"
    echo "Ajout de postGIS et pgSQL à la base de données"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS postgis;"  &>> ../var/log/install_db.log
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog; COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';"  &>> ../var/log/install_db.log
    sudo -n -u postgres -s psql -d $db_name -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";' &>> ../var/log/install_db.log

    # Création des schémas de la BDD
    echo "Création du schema utilisateurs..."
    cp ./usershub.sql /tmp/usershub.sql
    echo "" &>> ../var/log/install_db.log
    echo "" &>> ../var/log/install_db.log
    echo "--------------------" &>> ../var/log/install_db.log
    echo "" &>> ../var/log/install_db.log

    export PGPASSWORD=$owner_followdem_pass;psql -h $db_host -U $owner_followdem -d $db_name -f /tmp/usershub.sql &>> ../var/log/install_db.log

    echo "Création du schema followdem..."
    cp ./followdem_database.sql /tmp/followdem_database.sql
    echo "" &>> ../var/log/install_db.log
    echo "" &>> ../var/log/install_db.log
    echo "--------------------" &>> ../var/log/install_db.log
    echo "" &>> ../var/log/install_db.log

    export PGPASSWORD=$owner_followdem_pass;psql -h $db_host -U $owner_followdem -d $db_name -f /tmp/followdem_database.sql &>> ../var/log/install_db.log

fi