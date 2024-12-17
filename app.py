import config
import sys
import os

from flask import Flask, request
from flask_sqlalchemy import SQLAlchemy
from flask_sockets import Sockets
from flask_graphql_auth import GraphQLAuth
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

# Initialisation de l'application Flask
app = Flask(__name__, static_folder="static/")
app.secret_key = os.urandom(24)
app.config["SQLALCHEMY_DATABASE_URI"] = config.SQLALCHEMY_DATABASE_URI
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = config.SQLALCHEMY_TRACK_MODIFICATIONS
app.config["UPLOAD_FOLDER"] = config.WEB_UPLOADDIR
app.config['SECRET_KEY'] = 'dvga'
app.config["JWT_SECRET_KEY"] = 'dvga'
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = 120
app.config["JWT_REFRESH_TOKEN_EXPIRES"] = 30

auth = GraphQLAuth(app)
sockets = Sockets(app)
app.app_protocol = lambda environ_path_info: 'graphql-ws'

db = SQLAlchemy(app)

# Prometheus Metrics
REQUEST_COUNT = Counter(
    'app_requests_total', 
    'Total number of requests', 
    ['method', 'endpoint']
)

@app.before_request
def before_request():
    """ Compte les requêtes par méthode et endpoint """
    REQUEST_COUNT.labels(method=request.method, endpoint=request.path).inc()

@app.route('/metrics')
def metrics():
    """ Expose les métriques Prometheus """
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    sys.setrecursionlimit(100000)
    os.popen("python3 setup.py").read()

    from core.views import *
    from gevent import pywsgi
    from geventwebsocket.handler import WebSocketHandler
    from version import VERSION

    # Configuration de l'adresse et du port
    host = config.WEB_HOST
    port = int(config.WEB_PORT)

    server = pywsgi.WSGIServer((host, port), app, handler_class=WebSocketHandler)
    print("DVGA Server Version: {version} Running on {host}:{port}...".format(version=VERSION, host=host, port=port))
    server.serve_forever()
