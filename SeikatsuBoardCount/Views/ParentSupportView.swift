import SwiftUI
import MessageUI

// Deliberately independent of CountStore: feedback never reads or attaches records.
enum ParentSupportContent {
    static let email = "satoustudio.apps@gmail.com"
    static let supportURL = URL(string: "https://satou-studio.github.io/seikatsu-board-site/count-support.html")!
    static let reviewURL = URL(string: "https://apps.apple.com/app/id6794626819?action=write-review")!
    static var subject: String { String(localized: "support.mailSubject") }
    static var body: String { String(localized: "support.mailBody") }
}

struct ParentSupportEntry: View {
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("support.title", systemImage: "info.circle")
                .font(.subheadline)
                .frame(minHeight: 44)
                .padding(.horizontal, 12)
        }
        .accessibilityLabel(Text("support.title"))
        .accessibilityIdentifier("support.entry")
        .sheet(isPresented: $isPresented) { ParentSupportView() }
    }
}

struct ParentSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var showingMail = false
    @State private var showingMailFallback = false
    @State private var showingLinkFailure = false

    var body: some View {
        NavigationStack {
            ScrollView {
              VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("support.introduction")
                    action("support.help", detail: "support.webDetail", icon: "questionmark.circle", id: "support.help") {
                        open(ParentSupportContent.supportURL)
                    }
                    action("support.mail", detail: "support.mailDetail", icon: "envelope", id: "support.mail") {
                        if MFMailComposeViewController.canSendMail() {
                            showingMail = true
                        } else {
                            showingMailFallback = true
                        }
                    }
                    action("support.review", detail: "support.reviewDetail", icon: "square.and.pencil", id: "support.review") {
                        open(ParentSupportContent.reviewURL)
                    }
                }
                VStack(alignment: .leading, spacing: 16) {
                    Text("support.contact")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    Text(verbatim: ParentSupportContent.email)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel(Text("support.emailAddress"))
                        .accessibilityValue(ParentSupportContent.email)
                        .accessibilityIdentifier("support.address")
                    Text("support.privacy")
                    Text("support.manualSending")
                }
              }
              .font(.body)
              .fixedSize(horizontal: false, vertical: true)
              .padding(20)
            }
            .safeAreaInset(edge: .top) {
                supportHeader(title: "support.title", closeID: "support.close") { dismiss() }
            }
            .sheet(isPresented: $showingMail) {
                FeedbackMailComposer(isPresented: $showingMail)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showingMailFallback) {
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            Text("support.mailUnavailable").fixedSize(horizontal: false, vertical: true)
                            Text("support.mailUnavailableDetail").fixedSize(horizontal: false, vertical: true)
                            Text(verbatim: ParentSupportContent.email)
                                .textSelection(.enabled)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityLabel(Text("support.emailAddress"))
                                .accessibilityValue(ParentSupportContent.email)
                            Text(ParentSupportContent.subject).textSelection(.enabled)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(ParentSupportContent.body).textSelection(.enabled)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .font(.body)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(20)
                    }
                    .safeAreaInset(edge: .top) {
                        supportHeader(title: "support.mail", closeID: "support.mailFallbackClose") {
                            showingMailFallback = false
                        }
                    }
                }
            }
            .alert("support.linkFailed", isPresented: $showingLinkFailure) {
                Button("support.close", role: .cancel) {}
            } message: {
                Text("support.linkFailedDetail")
            }
        }
        .tint(.primary)
    }

    // Navigation-bar text caps its scaling on small screens. Keep the close
    // action outside that bar so it follows the full accessibility size range.
    private func supportHeader(title: LocalizedStringKey, closeID: String, close: @escaping () -> Void) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            Button(action: close) {
                Text("support.close")
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .accessibilityIdentifier(closeID)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemBackground))
    }

    private func action(_ title: LocalizedStringKey, detail: LocalizedStringKey, icon: String, id: String, perform: @escaping () -> Void) -> some View {
        Button(action: perform) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: icon).accessibilityHidden(true)
                    Text(title).fixedSize(horizontal: false, vertical: true)
                }
                .font(.body.weight(.semibold))
                Text(detail).font(.subheadline).foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
    }

    private func open(_ url: URL) {
        openURL(url) { accepted in
            if !accepted { showingLinkFailure = true }
        }
    }
}

private struct FeedbackMailComposer: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    func makeCoordinator() -> Coordinator { Coordinator(isPresented: $isPresented) }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setToRecipients([ParentSupportContent.email])
        controller.setSubject(ParentSupportContent.subject)
        controller.setMessageBody(ParentSupportContent.body, isHTML: false)
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isPresented: Bool
        init(isPresented: Binding<Bool>) { _isPresented = isPresented }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            isPresented = false
        }
    }
}
