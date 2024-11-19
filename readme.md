# 📄 CoverLetterApp

A user-friendly app to generate professional, tailored cover letters. Upload your CV and job description, and let the app create a personalized cover letter for you!

---

## ✨ Features
- 🖇️ **Upload CV**: Supports PDF and image formats.
- 📝 **Job Description Input**: Enter or paste the job description.
- 📄 **Cover Letter Generation**: Automatically creates a professional cover letter.
- 🔄 **Preview and Copy**: View and copy the generated cover letter.

---

## 🛠️ Tech Stack
- **Frontend**: SwiftUI (iOS app)
- **Backend**: Python + Flask
- **API**: Google Gemini API

---

## 🚀 Installation

### Backend Setup
1. Navigate to the `Backend` folder:
   
   ```bash
   cd Backend
   ```

2. Create a virtual environment:

   ```bash
   python3 -m venv myenv
   source myenv/bin/activate
   ```

3. Install dependencies:

   ```bash

   pip install -r requirements.txt
   ```

4. Add API keys:
   Create a config.json file:

   ```bash
   {
      "google_api_key": "YOUR_GOOGLE_API_KEY"
   }
   ```

5. Start the backend server:

   ```bash
   python app.py
   ```

6. Frontend Setup
Open the project in Xcode:

   ```bash
   Run the app on a simulator or a physical device.
   ```

## 📖 Usage
1. **Upload Your CV**: Select a PDF or image file.
2. **Input Job Description**: Paste the job description.
3. **Generate Cover Letter**: Click "Generate Cover Letter."
4. **Copy the Resulta**: Use the "Copy Cover Letter" button.

## 📡 API Endpoints
   ```bash
   POST /generate-cover-letter
   ```
   **Description**: Generates a tailored cover letter.

   **Request**:
   ```bash
   {
      "cv_text": "Extracted CV text",
      "job_description": "Job description text",
      "use_google": true
   }
   ```
   **Response**:
   ```bash
   {
      "cover_letter": "Generated cover letter text"
   }
   ```


## 📞 Contact
   **Author**: Nguyen Minh Duc
   
   **Email**: ducnguyen16042593@gmail.com


