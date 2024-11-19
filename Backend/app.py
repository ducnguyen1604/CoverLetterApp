'''
#
//  app.py
//  CoverLetterApp
//
//  Created by Nguyen Minh Duc on 19/11/24.
//
'''
from flask import Flask, request, jsonify
from CVProcessor import extract_sections
from PromptGenerator import generate_prompt, call_google_gemini_api

app = Flask(__name__)

@app.route('/generate-cover-letter', methods=['POST'])
def generate_cover_letter():
    # Parse request data
    data = request.json
    cv_text = data.get("cv_text", "")
    job_description = data.get("job_description", "")

    # Extract sections from CV text
    sections = extract_sections(cv_text)

    # Generate the prompt for the Gemini API
    prompt = generate_prompt(sections, job_description)

    # Call the Gemini API to generate the cover letter
    cover_letter = call_google_gemini_api(prompt)

    # Return the generated cover letter in the response
    return jsonify({"cover_letter": cover_letter})

if __name__ == "__main__":
    # Start the Flask server
    app.run(host="0.0.0.0", port=5001, debug=True)
