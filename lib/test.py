import joblib
import sklearn

# Load the saved encoders
encoders = joblib.load('../lib/encoders.pkl')

# Function to encode new user inputs using loaded encoders
def encode_input(user_input, encoders):
    encoded_input = {}
    for feature, value in user_input.items():
        if feature in encoders:
            encoded_input[feature] = encoders[feature].transform([value])[0]
        else:
            encoded_input[feature] = value  # For features that don't need encoding
    return encoded_input

# Example user input
user_input = {'Fever': 'Yes', 'Cough': 'No', 'Gender': 'Male', 'Age': 35}  # Assuming 'Age' doesn't need encoding

# Encode the input
encoded_input = encode_input(user_input, encoders)
