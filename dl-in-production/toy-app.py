from flask import Flask

app = Flask(__name__)


@app.route('/')
def hello():
    return 'Hello World!'


@app.route('/another-greeting')
def hi_there():
    return 'Hi there!'


@app.route('/square/<number>')
def square(number):
    number = int(number)
    return f"The square of {number} is {number**2}"
