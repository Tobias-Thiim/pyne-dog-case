# ingestion/main.py
import os
from flask import Flask, request
# Importér run-funktionen fra pipelinen
from ingestion import dog_pipeline

app = Flask(__name__)

@app.route('/run', methods=['GET', 'POST'])
def run_pipeline():
    # Valgfrit: simpel sikkerhedstjek med en header (hvis ønsket)
    expected_token = os.environ.get("INGESTION_TOKEN")  # definér i miljøvariabler
    if expected_token and request.headers.get("X-API-KEY") != expected_token:
        return ("Unauthorized", 401)
    # Kør pipelinen
    dog_pipeline.run()
    return ("Pipeline executed", 200)

if __name__ == '__main__':
    # Cloud Run injicerer PORT miljøvariablen, default 8080
    port = int(os.environ.get("PORT", 8080))
    app.run(host='0.0.0.0', port=port)
