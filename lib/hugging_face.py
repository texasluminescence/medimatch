from transformers import pipeline

# Load the model
classifier = pipeline("text-classification", model="Zabihin/Symptom_to_Diagnosis", tokenizer="Zabihin/Symptom_to_Diagnosis")

# Example input text
input_text = "coughing and fever"

# Get the predicted label
result = classifier(input_text)

# Print the predicted label
predicted_label = result[0]['label']
print("Predicted Label:", predicted_label)

#citation: https://huggingface.co/Zabihin/Symptom_to_Diagnosis