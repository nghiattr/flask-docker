from flask import Flask, request, render_template
import socket

app = Flask(__name__)

@app.route('/')
def home():
    info = {
        "hostname": socket.gethostname(),
        "your_ip": request.remote_addr
    }
    return render_template('index.html', info=info)

@app.route('/nghia')
def hello():
    return render_template('nghia.html')

@app.route('/sum/<int:a>/<int:b>')
def sum(a,b):
    return str(a+b)
