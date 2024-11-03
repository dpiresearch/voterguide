import requests
import os
import asyncio, json
import sounddevice as sd
import numpy as np
from pydub import AudioSegment
import datetime
import os
from openai import OpenAI

client = OpenAI()

def request_documentation_from_openai(transcription):
    prompt_content = {
        "role": "user",
        "content": transcription
    }

    base_conversation = [
        {"role": "system",
         "content": "You are a world class election expert on the upcoming November 2024 election and can make very good recommendations based on the background of the user asking the questions.  You will find out what the voter is voting for related to address given and will make recommendations on each candidate and specific issue.  Respond with the name of the candidate or title of the proposition, make the recommendation, and justify the recommendation basaed on the voter's background"},
        prompt_content
    ]

    completion = client.chat.completions.create(
        model="gpt-4o",
        messages=base_conversation
    )

    return_answer = completion.choices[0].message.content
    return return_answer

if __name__ == "__main__":

    try:
        address = "201 Van Ness, San Francisco 94102"
        prompt="Assume the voter is a 5 out 10 in fiscally conservative with 1 being not very to 10 being very fiscally conservation and the voter is a 8 out of 10 in socially progressive scale with 1 being not socially progressive ( traditional ) and 10 being very socially progressive, what is the voter voting for and make recommendations on each issue and candidate in the voter's ballot based on the address " + address
        documentation = request_documentation_from_openai(prompt)
        print(documentation)
    except Exception as e:
        print(f"An error occurred: {e}")

