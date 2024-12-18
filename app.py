import config
import sys
import os

from flask import Flask, request
from flask_sqlalchemy import SQLAlchemy
from flask_sockets import Sockets
from flask_graphql_auth import GraphQLAuth
from prometheus_flask_exporter import PrometheusMetrics

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
metrics = PrometheusMetrics(app)

# Static information
metrics.info('app_info', 'Application info', version='1.0.3')

# Example routes to track metrics
@app.route('/')
def main():
    return 'Welcome to DVGA!'  # requests tracked by default

@app.route('/skip')
@metrics.do_not_track()
def skip():
    return 'This route is not tracked.'

@app.route('/<item_type>')
@metrics.do_not_track()
@metrics.counter('invocation_by_type', 'Number of invocations by type',
                 labels={'item_type': lambda: request.view_args['item_type']})
def by_type(item_type):
    return f'Item type: {item_type}'  # only the counter is collected, not default metrics

@app.route('/long-running')
@metrics.gauge('in_progress', 'Long running requests in progress')
def long_running():
    import time
    time.sleep(5)  # simulate long processing
    return 'This request took a long time!'

@app.route('/status/<int:status>')
@metrics.do_not_track()
@metrics.summary('requests_by_status', 'Request latencies by status',
                 labels={'status': lambda r: r.status_code})
@metrics.histogram('requests_by_status_and_path', 'Request latencies by status and path',
                   labels={'status': lambda r: r.status_code, 'path': lambda: request.path})
def echo_status(status):
    return f'Status: {status}', status

if __name__ == '__main__':
    sys.setrecursionlimit(100000)
    os.popen("python3 setup.py").read()

    from core.views import *
    from gevent import pywsgi
    from geventwebsocket.handler import WebSocketHandler
    from version import VERSION

    server = pywsgi.WSGIServer((config.WEB_HOST, int(config.WEB_PORT)), app, handler_class=WebSocketHandler)
    print("DVGA Server Version: {version} Running...".format(version=VERSION))
    server.serve_forever()
