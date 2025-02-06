import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier

import groq
import json
import logging

import os
from dotenv import load_dotenv

load_dotenv()

#--------------------------------- Random Forest Classifier -----------------------------

df = pd.read_csv('DiseaseAndSymptoms.csv')

symptom_columns = [col for col in df.columns if 'Symptom_' in col]
unique_symptoms = set()
for col in symptom_columns:
    unique_symptoms.update(df[col].dropna().unique())

symptom_mapping = {symptom: idx for idx, symptom in enumerate(sorted(unique_symptoms))}

X = np.zeros((len(df), len(symptom_mapping)))
for i, row in df.iterrows():
    for col in symptom_columns:
        if pd.notna(row[col]):
            symptom_idx = symptom_mapping[row[col]]
            X[i, symptom_idx] = 1

le_disease = LabelEncoder()
y = le_disease.fit_transform(df['Disease'])
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
rf_model = RandomForestClassifier(n_estimators=100, random_state=42)
rf_model.fit(X_train, y_train)

def predict_disease(symptoms_input):
    input_vector = np.zeros(len(symptom_mapping))
    valid_symptoms = [s for s in symptoms_input if s in symptom_mapping]

    if not valid_symptoms:
        return "No valid symptoms provided"

    for symptom in valid_symptoms:
        input_vector[symptom_mapping[symptom]] = 1

    prediction = rf_model.predict([input_vector])
    return le_disease.inverse_transform(prediction)[0]

# Print available symptoms for reference
#print("Available symptoms in dataset:")
#print(sorted(list(symptom_mapping.keys())))

#symptoms = [' continuous_sneezing',' congestion']  # need to transform user input into actual
#predicted = predict_disease(symptoms)
#print(f"Predicted Disease: {predicted}")

#--------------------------------- Cross-val-score -------------------------------------

from sklearn.model_selection import cross_val_score

# Perform 5-fold cross-validation to check accuracy
cv_scores = cross_val_score(rf_model, X, y, cv=5)
#print(f"Cross-validation accuracy: {cv_scores.mean():.3f} (+/- {cv_scores.std() * 2:.3f})")

#--------------------------------- Decision Tree Classifier -----------------------------
from sklearn.tree import DecisionTreeClassifier

# Extract symptom columns and create mapping
symptom_columns = [col for col in df.columns if 'Symptom_' in col]
unique_symptoms = set()
for col in symptom_columns:
    unique_symptoms.update(df[col].dropna().unique())

symptom_mapping = {symptom: idx for idx, symptom in enumerate(sorted(unique_symptoms))}

# Create feature matrix
X = np.zeros((len(df), len(symptom_mapping)))
for i, row in df.iterrows():
    for col in symptom_columns:
        if pd.notna(row[col]):
            symptom_idx = symptom_mapping[row[col]]
            X[i, symptom_idx] = 1

# Prepare target variable
le_disease = LabelEncoder()
y = le_disease.fit_transform(df['Disease'])

# Split data and train model
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
dt_model = DecisionTreeClassifier(random_state=42)
dt_model.fit(X_train, y_train)

def predict_disease2(symptoms_input):
    input_vector = np.zeros(len(symptom_mapping))
    valid_symptoms = [s for s in symptoms_input if s in symptom_mapping]

    if not valid_symptoms:
        return "No valid symptoms provided"

    for symptom in valid_symptoms:
        input_vector[symptom_mapping[symptom]] = 1

    prediction = dt_model.predict([input_vector])
    return le_disease.inverse_transform(prediction)[0]

# Print available symptoms
#print("Available symptoms in dataset:")
#print(sorted(list(symptom_mapping.keys())))

#symptoms = [' continuous_sneezing',' congestion']  # need to transform user input into actual
#predicted2 = predict_disease2(symptoms)
#print(f"Predicted Disease: {predicted2}")

#----------------------------------- model cross verifcation -----------------------------------

class DiseaseVerifier:
    def __init__(self, api_key: str):
        self.client = groq.Client(api_key=api_key)
        self.logger = logging.getLogger(__name__)

    def verify_prediction(self, symptoms: str, predicted_disease: str) -> dict:
        # Construct a prompt that asks GPT to compare the symptoms with the predicted disease.
        
        #THIS PROMPT NEEDS TO BE REITERATED AND IMPROVED
        verification_prompt = f"""
        You are a medical expert. Analyze the following information:

        Symptoms: {symptoms}
        Predicted Disease: {predicted_disease}

        Based on your medical knowledge, determine whether the predicted disease is a plausible diagnosis given the symptoms.
        Please provide your answer as a JSON object in the following format:
        {{
            "prediction_valid": true or false,
            "confidence": <number between 0 and 1 (rounded to two decimal places)>,
            "explanation": "<a brief explanation>"
        }}
        """
        
        try:
            response = self.client.chat.completions.create(
                model="deepseek-r1-distill-llama-70b",
                messages=[
                    {"role": "system", "content": "You are a knowledgeable and unbiased medical diagnostic expert."},
                    {"role": "user", "content": verification_prompt}
                ],
                response_format={"type": "json_object"},
            )
            
            # Extract and parse the response content.
            content = response.choices[0].message.content.strip()
            result = json.loads(content)
            return result
        
        except Exception as e:
            self.logger.error(f"Error verifying disease prediction: {str(e)}")
            # In case of error, return a default response.
            return {
                "prediction_valid": False,
                "confidence": 0.0,
                "explanation": "Verification failed due to an error."
            }


# Testing the function

# The symptoms provided by the user (as a comma-separated string)
symptoms = [' continuous_sneezing',' congestion']
predicted_random_forest = predict_disease(symptoms)
print(predicted_random_forest)
predicted_decision_tree = predict_disease2(symptoms)
print(predicted_decision_tree)

# Initialize the verifier with your OpenAI API key
API_KEY = os.environ.get("GROQ_API_KEY")
verifier = DiseaseVerifier(API_KEY)

# Verify the prediction
verification_result = verifier.verify_prediction(symptoms, predicted_random_forest)
print("Verification Result:", verification_result)
