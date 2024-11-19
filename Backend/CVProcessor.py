'''
#
//  CVProcessor.py
//  CoverLetterApp
//
//  Created by Nguyen Minh Duc on 19/11/24.
//
'''
import re

def extract_sections(text):
    """
    Extract sections like education, experience, projects, achievements, and skills.
    """
    sections = {
        "Education": extract_section(text, ["Education", "Qualifications"]),
        "Experience": extract_section(text, ["Experience", "Work History"]),
        "Projects": extract_section(text, ["Projects", "Portfolio"]),
        "Achievements": extract_section(text, ["Achievements", "Awards"]),
        "Skills": extract_section(text, ["Skills", "Competencies"])
    }
    return sections

def extract_section(text, keywords):
    """
    Extract a section of the text based on keywords. Dynamically determine the section's boundaries.
    """
    # Compile a regex pattern for all keywords
    section_pattern = "|".join(keywords)
    pattern = rf"(?i)(?:{section_pattern})(.*?)(?=\n[A-Z])"  
    matches = re.finditer(pattern, text, re.DOTALL)

    for match in matches:
        # Extract and clean up the matched section
        section_content = match.group(1).strip()
        if section_content:
            return section_content

    return "Not Found"
