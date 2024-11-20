//
//  ContentView.swift
//  CoverLetterApp
//
//  Created by Nguyen Minh Duc on 19/11/24.
//

import SwiftUI
import UniformTypeIdentifiers
import PDFKit
import Vision

struct ContentView: View {
    @State private var extractedText: String = "" // Store extracted text for backend
    @State private var jobDescription: String = ""
    @State private var coverLetter: String = "Your generated cover letter will appear here."
    @State private var isFilePickerPresented: Bool = false
    @State private var filePreview: AnyView? = nil // Store the file preview
    @State private var showCopyConfirmation: Bool = false // State to show confirmation alert after copying

    var body: some View {
        NavigationView {
            ScrollView { // Enable scrolling for the whole page
                VStack(spacing: 20) {
                    // Intro Text
                    Text("Put your CV and job description here to generate a cover letter.")
                        .font(.body) // Normal font
                        .multilineTextAlignment(.center) // Center-aligned text
                        .lineLimit(nil) // Allow unlimited lines
                        .fixedSize(horizontal: false, vertical: true) // Prevent truncation
                        .padding()

                    // CV Upload Button and Preview
                    Button(action: {
                        isFilePickerPresented.toggle()
                    }) {
                        Text("Upload CV")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    // CV Preview
                    if let preview = filePreview {
                        preview
                            .frame(maxHeight: UIScreen.main.bounds.height * 0.6) // Take 60% of the screen height
                            .cornerRadius(10)
                            .padding()
                    } else {
                        Text("No preview available.")
                            .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }

                    // Job Description Input
                    TextField("Enter the job description", text: $jobDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .frame(height: 100) // Default height for 5 lines
                        .lineLimit(5) // Allow up to 5 visible lines by default
                        .cornerRadius(10)

                    // Generate Button
                    Button(action: generateCoverLetter) {
                        Text("Generate Cover Letter")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    // Cover Letter Output and Copy Button
                    ScrollView {
                        ScrollView(.vertical) { // Enable vertical scrolling inside the output box
                            Text(coverLetter)
                                .font(.title2) // Larger font for readability
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil) // Allow unlimited lines
                        }
                        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.6) // Restrict to 60% of screen height
                    }
                    .padding()


                    // Copy Button
                    Button(action: copyCoverLetter) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Cover Letter")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    .alert(isPresented: $showCopyConfirmation) {
                        Alert(
                            title: Text("Copied"),
                            message: Text("Cover letter copied to clipboard."),
                            dismissButton: .default(Text("OK"))
                        )
                    }

                    Spacer()
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .padding()
                .navigationTitle("Cover Letter Generator")
                .fileImporter(
                    isPresented: $isFilePickerPresented,
                    allowedContentTypes: [.pdf, .image], // Accept PDFs and images
                    allowsMultipleSelection: false
                ) { result in
                    handleFileImport(result: result)
                }
            }
        }
    }


    // Copy Cover Letter to Clipboard
    private func copyCoverLetter() {
        UIPasteboard.general.string = coverLetter // Copy the generated cover letter to the clipboard
        showCopyConfirmation = true // Show confirmation alert
    }

    // Generate Cover Letter
    func generateCoverLetter() {
        guard let url = URL(string: "http://192.168.0.103:5001/generate-cover-letter") else { return } // Update your backend URL here
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "cv_text": extractedText,
            "job_description": jobDescription
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                DispatchQueue.main.async {
                    coverLetter = "Failed to generate cover letter: \(error.localizedDescription)"
                }
                return
            }

            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([String: String].self, from: data) {
                    DispatchQueue.main.async {
                        coverLetter = decodedResponse["cover_letter"] ?? "Error: Unable to fetch the cover letter."
                    }
                } else {
                    DispatchQueue.main.async {
                        coverLetter = "Error: Failed to decode server response."
                    }
                }
            }
        }.resume()
    }

    // Handle File Import
    private func handleFileImport(result: Result<[URL], Error>) {
        do {
            let selectedFiles = try result.get()
            if let fileURL = selectedFiles.first {
                if fileURL.pathExtension.lowercased() == "pdf" {
                    // Extract text from PDF
                    extractedText = extractTextFromPDF(url: fileURL) ?? "Unable to extract text from PDF."
                    filePreview = AnyView(PDFPreviewView(url: fileURL))
                } else if ["png", "jpg", "jpeg"].contains(fileURL.pathExtension.lowercased()) {
                    // Extract text from Image
                    extractTextFromImage(url: fileURL) { text in
                        extractedText = text ?? "Unable to extract text from image."
                    }
                    filePreview = AnyView(ImagePreviewView(url: fileURL))
                } else {
                    extractedText = "Unsupported file type."
                    filePreview = nil
                }
            }
        } catch {
            extractedText = "File selection failed: \(error.localizedDescription)"
            filePreview = nil
        }
    }

    // Extract Text from PDF
    private func extractTextFromPDF(url: URL) -> String? {
        guard let pdfDocument = PDFDocument(url: url) else { return nil }
        var fullText = ""
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex), let text = page.string {
                fullText += text + "\n"
            }
        }
        return fullText
    }

    // Extract Text from Image
    private func extractTextFromImage(url: URL, completion: @escaping (String?) -> Void) {
        guard let image = CIImage(contentsOf: url) else {
            completion(nil)
            return
        }

        let requestHandler = VNImageRequestHandler(ciImage: image, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            if let observations = request.results as? [VNRecognizedTextObservation] {
                let recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                completion(recognizedText)
            } else {
                completion(nil)
            }
        }
        request.recognitionLevel = .accurate

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                completion(nil)
            }
        }
    }
}

// PDF Preview View
struct PDFPreviewView: View {
    let url: URL

    var body: some View {
        PDFKitRepresentedView(url: url)
            .background(Color.gray.opacity(0.1))
    }
}

// PDFKit Representation for SwiftUI
struct PDFKitRepresentedView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// Image Preview View
struct ImagePreviewView: View {
    let url: URL

    var body: some View {
        if let image = UIImage(contentsOfFile: url.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Text("Unable to load image preview.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

