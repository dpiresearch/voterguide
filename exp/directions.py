import requests
import os

api_key = os.getenv("GOOGLE_API_KEY")

def fetch_directions():
    # Define the API endpoint
    url = "https://maps.googleapis.com/maps/api/directions/json"

    # Set up the parameters in a dictionary
    params = {
        'origin': 'Bart Way, Fremont, CA',
        'destination': '31 Reed Street, San Francisco 94104',
        'mode': 'transit',
        'key': api_key,
        'alternatives':True
    }

    # Make the GET request
    response = requests.get(url, params=params)

    # Check if the request was successful
    if response.status_code == 200:
        # Parse the JSON response
        data = response.json()
        print("Request successful!")
        return data
    else:
        print(f"Failed to retrieve directions. Status code: {response.status_code}")
        return None

# Example usage
# directions_data = fetch_directions()['routes'][0]['legs'][0]['duration']['text']
directions_data = fetch_directions()
if directions_data:
    print(directions_data)  # Print the parsed JSON data
