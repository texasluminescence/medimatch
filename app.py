from flask import Flask, request, jsonify
from flask_cors import CORS
from medimatchpoc import predictDisease

app = Flask(__name__)
CORS(app)  # Allow all origins

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.json
        print("Received data:", data)
        symptoms = data.get("symptoms", "")
        if not symptoms:
            return jsonify({"error": "Symptoms are required."}), 400

        result = predictDisease(symptoms)

        result = predictDisease(symptoms)
        return jsonify({
            "final_prediction": result["final_prediction"],
            "votes": result["votes"]
        })

    except Exception as e:
        import traceback
        print("Exception:", traceback.format_exc())
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000, host='0.0.0.0')