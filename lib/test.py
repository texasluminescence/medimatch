import numpy as np
import joblib
from catboost import CatBoostClassifier

# Load the model from a file
def load_model(file_path):
    return joblib.load(file_path)

# Preprocess user input
def preprocess_input(user_input):
    # Assuming user_input is a dictionary with feature values
    # Example: {'Age': 30, 'BP': 120, 'Cholesterol': 200, 'Gender': 'Male', 'Fever': 'Yes'}
    # Convert categorical data and scale/normalize if necessary, as was done during model training
    # This is a placeholder; you'll need to adjust preprocessing to fit your model's training
    features = np.array([[user_input['Age'], user_input['BP'], user_input['Cholesterol'], 
                          user_input['Gender'], user_input['Fever']]])
    return features

# Function to predict disease
def predict_disease(model, user_input):
    processed_input = preprocess_input(user_input)
    prediction = model.predict(processed_input)
    return prediction

# Main function to load the model and make a prediction
def main():
    file_path = '/Users/pranavbelligundu/Documents/GitHub/medimatch/lib/disease_prediction_model.pkl'  # Update the path as needed
    # Example user input, this should come from some user interface or API request in a real application
    user_input = {
        'Age': 35,
        'BP': 130,
        'Cholesterol': 180,
        'Gender': 'Male',  # Assume the model expects numerical encoding for categorical variables
        'Fever': 'No'
    }
    model = load_model(file_path)
    prediction = predict_disease(model, user_input)
    print(f"Predicted Disease: {prediction}")

if __name__ == "__main__":
    main()
