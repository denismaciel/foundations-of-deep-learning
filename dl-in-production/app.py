from flask import Flask, jsonify, request
from keras.models import load_model
import numpy as np

app = Flask(__name__)

model = load_model('model.h5')


@app.route('/home', methods=['GET'])
def home():
    return """
    Hi! This is a Flask app.
    You can get some predictions by hitting the /predictions endpoint.
    """


@app.route('/predict', methods=['POST'])
def predict():
    # get all the data passed by the client in the request
    data_client = request.get_json()

    input_data = data_client['input']

    input_array = np.array(input_data, dtype=float)/255
    out = model.predict(input_array)
    out = np.ndarray.tolist(out)

    return jsonify(out)


if __name__ == "main":
    app.run(port=8080, debug=True)
