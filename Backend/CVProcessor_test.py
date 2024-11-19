import unittest
from CVProcessor import extract_section, extract_sections

class TestCVProcessor(unittest.TestCase):

    def setUp(self):
        # Sample CV text for testing
        self.cv_text = """
        Education
        Bachelor of Science in Computer Science
        XYZ University, 2020

        Experience
        Software Engineer at ABC Corp
        Worked on AI and machine learning projects.

        Projects
        AI-powered chatbot development

        Achievements
        Employee of the Year, 2021

        Skills
        Python, Machine Learning, NLP, Swift
        """

    def test_extract_section_found(self):
        # Test extracting "Education" section
        education_keywords = ["Education", "Qualifications"]
        result = extract_section(self.cv_text, education_keywords)
        self.assertIn("Bachelor of Science in Computer Science", result)

    def test_extract_section_not_found(self):
        # Test when a section is not found
        awards_keywords = ["Awards", "Certifications"]
        result = extract_section(self.cv_text, awards_keywords)
        self.assertEqual(result, "Not Found")

    def test_extract_sections(self):
        # Test extracting all sections
        sections = extract_sections(self.cv_text)
        self.assertIn("Bachelor of Science in Computer Science", sections["Education"])
        self.assertIn("Software Engineer at ABC Corp", sections["Experience"])
        self.assertIn("AI-powered chatbot development", sections["Projects"])
        self.assertIn("Employee of the Year", sections["Achievements"])
        self.assertIn("Python", sections["Skills"])

if __name__ == "__main__":
    unittest.main()
