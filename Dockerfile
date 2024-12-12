FROM python:3.7-alpine

LABEL description="Damn Vulnerable GraphQL Application"
LABEL github="https://github.com/dolevf/Damn-Vulnerable-GraphQL-Application"
LABEL maintainers="Dolev Farhi & Connor McKinnon & Nick Aleks"

ARG TARGET_FOLDER=/opt/dvga
WORKDIR $TARGET_FOLDER/

# Install required dependencies
RUN apk add --update curl && rm -rf /var/cache/apk/*

# Create dvga user and group
RUN adduser -D -s /bin/sh dvga && mkdir -p $TARGET_FOLDER && chown dvga:dvga $TARGET_FOLDER

# Switch to dvga user
USER dvga

# Set up Python virtual environment
RUN python -m venv venv && source venv/bin/activate && pip3 install --upgrade pip --no-warn-script-location --disable-pip-version-check

# Add application files with ownership set to dvga:dvga
ADD --chown=dvga:dvga core /opt/dvga/core
ADD --chown=dvga:dvga db /opt/dvga/db
ADD --chown=dvga:dvga static /opt/dvga/static
ADD --chown=dvga:dvga templates /opt/dvga/templates
COPY --chown=dvga:dvga app.py /opt/dvga
COPY --chown=dvga:dvga config.py /opt/dvga
COPY --chown=dvga:dvga setup.py /opt/dvga/
COPY --chown=dvga:dvga version.py /opt/dvga/
COPY --chown=dvga:dvga requirements.txt /opt/dvga/

# Install Python dependencies
RUN pip3 install -r requirements.txt --user --no-warn-script-location
RUN python setup.py

# Expose application port
EXPOSE 5013/tcp

# Run the application
CMD ["python", "app.py"]
