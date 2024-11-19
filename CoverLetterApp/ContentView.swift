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

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Intro Text
                Text("Put your CV and job description here to generate a cover letter.")
                    .font(.body) // Normal font
                    .multilineTextAlignment(.center) // Center-aligned text
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
                    .frame(maxHeight: 150)
                    .lineLimit(5)

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

                // Cover Letter Output
                ScrollView {
                    Text(coverLetter)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .frame(maxHeight: 200)

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

    // Generate Cover Letter (Placeholder)
    func generateCoverLetter() {
        coverLetter = "This is a mock cover letter based on your CV and job description."
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
