import SwiftUI

struct IngestView: View {
    @State private var viewModel = IngestViewModel()

    var body: some View {
        List {
            // MARK: Input
            Section {
                TextField("YouTube URL", text: $viewModel.url)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Button {
                    Task { await viewModel.ingest() }
                } label: {
                    HStack {
                        Text("Start Pipeline")
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        }
                    }
                }
                .disabled(!viewModel.canSubmit)
            } header: {
                Text("Add Video")
            } footer: {
                Text("Paste a YouTube URL to fetch transcript, generate summary, and classify topics.")
            }

            // MARK: Result
            if let result = viewModel.result {
                Section {
                    row("Status", value: result.status)
                    row("Channel", value: "#\(result.channelId)")
                    row("Video", value: "#\(result.videoId)")
                    if let transcriptId = result.transcriptId {
                        row("Transcript", value: "#\(transcriptId)")
                    }
                    if let summaryId = result.summaryId {
                        row("Summary", value: "#\(summaryId)")
                    }
                } header: {
                    Text("Result")
                }

                Section {
                    if let action = result.videoAction {
                        row("Video", value: action)
                    }
                    if let action = result.transcriptAction {
                        row("Transcript", value: action)
                    }
                    if let action = result.summaryAction {
                        row("Summary", value: action)
                    }
                    if let action = result.classificationAction {
                        row("Classification", value: action)
                    }
                } header: {
                    Text("Actions")
                }
            }

            // MARK: Error
            if let error = viewModel.error {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                } header: {
                    Text("Error")
                }
            }
        }
        .navigationTitle("Ingest")
    }

    private func row(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
