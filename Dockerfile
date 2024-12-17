FROM python:3.11-alpine

LABEL description="Damn Vulnerable GraphQL Application with Prometheus Metrics"
LABEL github="https://github.com/dolevf/Damn-Vulnerable-GraphQL-Application"
LABEL maintainers="Dolev Farhi & Connor McKinnon & Nick Aleks"

# Définir les variables
ARG TARGET_FOLDER=/opt/dvga
WORKDIR $TARGET_FOLDER/

# Installer les dépendances système
RUN apk add --no-cache curl gcc libc-dev python3-dev

# Ajouter un utilisateur non-root pour des raisons de sécurité
RUN adduser -D dvga
RUN chown dvga. $TARGET_FOLDER/
USER dvga

# Créer un virtualenv et mettre à jour pip
RUN python -m venv venv
ENV PATH="$TARGET_FOLDER/venv/bin:$PATH"

# Installer les dépendances Python
COPY --chown=dvga:dvga requirements.txt /opt/dvga/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt --no-cache-dir

# Copier les fichiers d'application
ADD --chown=dvga:dvga core /opt/dvga/core
ADD --chown=dvga:dvga db /opt/dvga/db
ADD --chown=dvga:dvga static /opt/dvga/static
ADD --chown=dvga:dvga templates /opt/dvga/templates
COPY --chown=dvga:dvga app.py /opt/dvga
COPY --chown=dvga:dvga config.py /opt/dvga
COPY --chown=dvga:dvga setup.py /opt/dvga/
COPY --chown=dvga:dvga version.py /opt/dvga/

# Exécuter les prérequis setup
RUN python setup.py

# Exposer le port pour Flask
EXPOSE 5013

# Lancer l'application
CMD ["python", "app.py"]
