import json
import numpy as np
from catboost import CatBoostClassifier

# Function to load the model
def load_model(file_path):
    with open(file_path, 'r') as file:
        model_json = json.load(file)
    model = CatBoostClassifier()
    model.load_model(model_json, format='json')
    return model

# Preprocess user input (this is a placeholder, adjust according to your actual needs)
def preprocess_input(user_input):
    # Example: Convert user input into a format suitable for the model (e.g., numerical data)
    # This should match the preprocessing done during model training
    processed_input = np.array([user_input])  # This is a simplified placeholder
    return processed_input

# Function to predict disease
def predict_disease(model, user_input):
    processed_input = preprocess_input(user_input)
    prediction = model.predict(processed_input)
    return prediction

# Main function to load the model and make a prediction
def main():
    file_path = 'catboost_training.json'
    user_input = "cough, cold, fever"  # This should be replaced by actual user input
    model = load_model(file_path)
    prediction = predict_disease(model, user_input)
    print(f"Predicted Disease: {prediction}")

if __name__ == "__main__":
    main()
