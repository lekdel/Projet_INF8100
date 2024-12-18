FROM python:3.11-alpine

LABEL description="Damn Vulnerable GraphQL Application"
LABEL github="https://github.com/dolevf/Damn-Vulnerable-GraphQL-Application"
LABEL maintainers="Dolev Farhi & Connor McKinnon & Nick Aleks"

ARG TARGET_FOLDER=/opt/dvga
WORKDIR $TARGET_FOLDER/

# Installer curl, gcc et dépendances nécessaires
RUN apk add --no-cache curl gcc libc-dev python3-dev

# Ajouter un utilisateur non-root
RUN adduser -D dvga

# Créer le répertoire et ajuster les permissions
RUN mkdir -p $TARGET_FOLDER && chown dvga:dvga $TARGET_FOLDER

# Passer à l'utilisateur non-root
USER dvga

# Environnement virtuel et installation des dépendances
RUN python -m venv venv
RUN source venv/bin/activate && pip install --upgrade pip

# Copier les fichiers nécessaires
COPY --chown=dvga:dvga core /opt/dvga/core
COPY --chown=dvga:dvga db /opt/dvga/db
COPY --chown=dvga:dvga static /opt/dvga/static
COPY --chown=dvga:dvga templates /opt/dvga/templates
COPY --chown=dvga:dvga app.py /opt/dvga
COPY --chown=dvga:dvga config.py /opt/dvga
COPY --chown=dvga:dvga setup.py /opt/dvga/
COPY --chown=dvga:dvga version.py /opt/dvga/
COPY --chown=dvga:dvga requirements.txt /opt/dvga/

# Installer les dépendances Python
RUN source venv/bin/activate && pip install -r requirements.txt

# Lancer le setup
RUN python setup.py

EXPOSE 5013/tcp
CMD ["python", "app.py"]
