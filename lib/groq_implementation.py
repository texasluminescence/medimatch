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

import json
import pandas as pd
import logging
import groq

class DiseaseVerifier:
    def __init__(self, api_key: str, dataset_path: str):
        self.client = groq.Client(api_key=api_key)
        self.logger = logging.getLogger(__name__)
        self.dataset_path = dataset_path
        self.disease_symptom_mapping = self._load_disease_symptom_mapping()

    def _load_disease_symptom_mapping(self):
        """
        Loads the disease-to-symptom mapping from the dataset and returns it as a dictionary.
        """
        try:
            df = pd.read_csv(self.dataset_path)
            
            disease_symptom_mapping = {}

            for _, row in df.iterrows():
                disease = row["Disease"]
                symptoms = row.drop("Disease").dropna().tolist()  # Remove NaNs and extract symptoms
                
                if disease in disease_symptom_mapping:
                    disease_symptom_mapping[disease].update(symptoms)  # Add unique symptoms
                else:
                    disease_symptom_mapping[disease] = set(symptoms)

            # Convert sets to sorted lists for consistency
            return {disease: sorted(list(symptoms)) for disease, symptoms in disease_symptom_mapping.items()}

        except Exception as e:
            self.logger.error(f"Error loading dataset: {str(e)}")
            return {}

    def verify_prediction(self, symptoms: list, predicted_disease: str) -> dict:
        """
        Verifies the predicted disease against symptoms using an LLM.
        """
        # Convert disease-to-symptoms mapping into a JSON-friendly format
        disease_symptom_summary = json.dumps(self.disease_symptom_mapping, indent=2)
        print(disease_symptom_summary)

        # Construct a refined verification prompt
        verification_prompt = f"""
        You are an experienced medical diagnostic AI with specialized knowledge in disease identification. 
        Your task is to assess whether the predicted disease is a **plausible** diagnosis based on the provided symptoms.

        ### **Dataset Reference**
        To assist you, here is a mapping of known diseases and their associated symptoms. Don't completely base your thinking on this data, 
        use it for context: {disease_symptom_summary}

        ### **Guidelines for Verification**
        1. **Compare the provided symptoms** with the symptoms listed for the predicted disease.
        2. If the symptoms **strongly match**, return `prediction_valid: true` with **high confidence** (0.8–1.0).
        3. If there is a **partial match** (some missing or unexpected symptoms), return a **moderate confidence score** (0.4–0.7) and explain the discrepancy.
        4. If the symptoms **do not match at all**, return `prediction_valid: false` with **low confidence** (0.0–0.3), explaining the inconsistency.
        5. If the predicted disease seems incorrect, **suggest a more likely disease** based on the dataset.

        ### **Input Data**
        - **Symptoms Provided by User:** {symptoms}
        - **Predicted Disease from AI Model:** {predicted_disease}

        ### **Output Format (strict JSON)**
        Your response must be a JSON object in the exact format below:
        {{
            "prediction_valid": true or false,
            "confidence": <number between 0 and 1, rounded to two decimal places>,
            "explanation": "<A concise but medically sound explanation>",
            "suggested_disease": "<If incorrect, suggest a more likely disease. Otherwise, return 'N/A'>"
        }}

        Ensure that your response is **medically accurate, concise, and based on the dataset provided**.
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
            return {
                "prediction_valid": False,
                "confidence": 0.0,
                "explanation": "Verification failed due to an error.",
                "suggested_disease": "N/A"
            }


#TESTING

# The symptoms provided by the user (as a comma-separated string)
symptoms = [' continuous_sneezing',' congestion']
predicted_random_forest = predict_disease(symptoms)
print(predicted_random_forest)
predicted_decision_tree = predict_disease2(symptoms)
print(predicted_decision_tree)

# Initialize the verifier with your OpenAI API key
API_KEY = os.environ.get("GROQ_API_KEY")
dataset_path = 'DiseaseAndSymptoms.csv'
verifier = DiseaseVerifier(API_KEY,dataset_path)

testing = pd.read_csv('test_symptoms_sample.csv')


for index, row in testing.iterrows():
    # Extract non-null symptom values into a list
    symptoms = [' ' + str(symptom).strip() for symptom in row.tolist() if pd.notna(symptom)]
    print(symptoms)
    
    predicted_random_forest = predict_disease(symptoms)
    
    # Verify the prediction
    verification_result = verifier.verify_prediction(symptoms, predicted_random_forest)

    print(f"Row {index+1} Symptoms: {symptoms}")
    print("Prediction:", predicted_random_forest)
    print("Verification Result:", verification_result)
    print("-" * 50)

# Verify the prediction
#verification_result = verifier.verify_prediction(symptoms, predicted_random_forest)
#print("Verification Result:", verification_result)
