# -*- coding: utf-8 -*-

# Sources:
# Susobhan Akhuli

# pip install google-generativeai --upgrade

import numpy as np
import pandas as pd
from scipy.stats import mode
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.svm import SVC
from sklearn.naive_bayes import GaussianNB
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix
import os
import google.generativeai as genai
from scipy import stats
from dotenv import load_dotenv
load_dotenv()

def normalize_symptom(symptom):
    return " ".join([i.capitalize() for i in symptom.strip().split(" ")])
# Load dataset
DATA_PATH = "Training.csv"
data = pd.read_csv(DATA_PATH).dropna(axis=1)

# Encode labels
encoder = LabelEncoder()
data["prognosis"] = encoder.fit_transform(data["prognosis"])

# Define features and labels
X = data.iloc[:, :-1]
y = data.iloc[:, -1]

# Train models on full dataset
final_svm_model = SVC()
final_nb_model = GaussianNB()
final_rf_model = RandomForestClassifier(random_state=18)
final_svm_model.fit(X, y)
final_nb_model.fit(X, y)
final_rf_model.fit(X, y)

# Read and prepare test data for combined model accuracy
test_data = pd.read_csv("Testing.csv").dropna(axis=1)
test_X = test_data.iloc[:, :-1]
test_Y = encoder.transform(test_data.iloc[:, -1])

svm_preds = final_svm_model.predict(test_X)
nb_preds = final_nb_model.predict(test_X)
rf_preds = final_rf_model.predict(test_X)
final_preds = [stats.mode([i, j, k])[0] for i, j, k in zip(svm_preds, nb_preds, rf_preds)]

print(f"Accuracy on Test dataset by the combined model: {accuracy_score(test_Y, final_preds) * 100}")

# Create symptom index dictionary
symptoms = X.columns.values
symptom_index = {normalize_symptom(value.replace("_", " ")): index for index, value in enumerate(symptoms)}
data_dict = {
    "symptom_index": symptom_index,
    "predictions_classes": encoder.classes_
}

def predictDisease(symptoms):
    symptoms = symptoms.split(",")
    input_data = [0] * len(data_dict["symptom_index"])
    for symptom in symptoms:
        symptom = normalize_symptom(symptom)
        if symptom in data_dict["symptom_index"]:
            index = data_dict["symptom_index"][symptom]
            input_data[index] = 1

    input_data = np.array(input_data).reshape(1, -1)

    rf_prediction = data_dict["predictions_classes"][final_rf_model.predict(input_data)[0]]
    nb_prediction = data_dict["predictions_classes"][final_nb_model.predict(input_data)[0]]
    svm_prediction = data_dict["predictions_classes"][final_svm_model.predict(input_data)[0]]

    votes = [rf_prediction, nb_prediction, svm_prediction]
    final_prediction = max(set(votes), key=votes.count)
    vote_count = votes.count(final_prediction)

    return {
        "final_prediction": final_prediction,
        "votes": f"{vote_count} of {len(votes)} models"
    }   

# Configure Gemini API
GEMINI_API_KEY = ''
os.environ["GEMINI_API_KEY"] = os.getenv("GEMINI_API_KEY")
genai.configure(api_key=os.environ["GEMINI_API_KEY"])
model = genai.GenerativeModel("gemini-2.0-flash")

def check_diagnosis_and_get_treatments(symptoms, diagnosis):
    prompt = f"""
    Given the following symptoms: {symptoms}
    and the diagnosis: {diagnosis}

    Please tell me:
    1. Is this a valid diagnosis based on the symptoms?
    2. What are the possible treatments for this diagnosis?
    """
    response = model.generate_content(prompt)
    return response.text

# Evaluation and testing logic (only runs directly)
if __name__ == "__main__":
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=24)

    testing_df = X_test.copy()
    testing_df["prognosis"] = encoder.inverse_transform(y_test)
    testing_df.to_csv("Testing.csv", index=False)
    print("Testing.csv created.")

    def cv_scoring(estimator, X, y):
        return accuracy_score(y, estimator.predict(X))

    models = {
        "SVC": SVC(),
        "Gaussian NB": GaussianNB(),
        "Random Forest": RandomForestClassifier(random_state=18)
    }

    for model_name in models:
        model = models[model_name]
        scores = cross_val_score(model, X, y, cv=10, n_jobs=-1, scoring=cv_scoring)
        print("==" * 30)
        print(model_name)
        print(f"Scores: {scores}")
        print(f"Mean Score: {np.mean(scores)}")

    svm_model = SVC()
    svm_model.fit(X_train, y_train)
    print(f"Accuracy on train data by SVM Classifier: {accuracy_score(y_train, svm_model.predict(X_train)) * 100}")
    print(f"Accuracy on test data by SVM Classifier: {accuracy_score(y_test, svm_model.predict(X_test)) * 100}")

    nb_model = GaussianNB()
    nb_model.fit(X_train, y_train)
    print(f"Accuracy on train data by Naive Bayes Classifier: {accuracy_score(y_train, nb_model.predict(X_train)) * 100}")
    print(f"Accuracy on test data by Naive Bayes Classifier: {accuracy_score(y_test, nb_model.predict(X_test)) * 100}")

    rf_model = RandomForestClassifier(random_state=18)
    rf_model.fit(X_train, y_train)
    print(f"Accuracy on train data by Random Forest Classifier: {accuracy_score(y_train, rf_model.predict(X_train)) * 100}")
    print(f"Accuracy on test data by Random Forest Classifier: {accuracy_score(y_test, rf_model.predict(X_test)) * 100}")

    print(predictDisease("fever, cough"))
    print(data_dict["symptom_index"])

    symptoms_input = input("Enter Symptoms, Comma separated no Spaces:")
    diagnosis_input = predictDisease(symptoms_input)
    response = check_diagnosis_and_get_treatments(symptoms_input, diagnosis_input)
    print(response)
