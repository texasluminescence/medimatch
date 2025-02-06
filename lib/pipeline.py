import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier

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

symptoms = [' continuous_sneezing',' congestion']  # need to transform user input into actual
predicted = predict_disease(symptoms)
print(f"Predicted Disease: {predicted}")

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

symptoms = [' continuous_sneezing',' congestion']  # need to transform user input into actual
predicted2 = predict_disease2(symptoms)
print(f"Predicted Disease: {predicted2}")

