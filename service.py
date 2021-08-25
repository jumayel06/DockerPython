from flask import Flask
from utils.util import *


app = Flask(__name__)


@app.route('/api/v1/execute', methods=['GET'])
def welcome():

    return 'Hello %s' % get_name()
