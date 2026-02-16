import SwiftUI

import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    private var sharedURL: String?
    private var sharedText: String?
    private var sharedImage: UIImage?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Save Bookmark"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var urlLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var folderButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.title = "Select Folder"
        config.image = UIImage(systemName: "folder")
        config.imagePadding = 8
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(selectFolder), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var aiSortButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "AI Auto-Sort & Save"
        config.image = UIImage(systemName: "sparkles")
        config.imagePadding = 8
        config.baseBackgroundColor = .systemPurple
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(aiAutoSortAndSave), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Save to Selected Folder"
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(saveBookmark), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Cancel"
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        setupUI()
        extractSharedContent()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(previewImageView)
        containerView.addSubview(urlLabel)
        containerView.addSubview(aiSortButton)
        containerView.addSubview(folderButton)
        containerView.addSubview(saveButton)
        containerView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            previewImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            previewImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            previewImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            previewImageView.heightAnchor.constraint(equalToConstant: 120),
            
            urlLabel.topAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: 12),
            urlLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            urlLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            aiSortButton.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 20),
            aiSortButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            aiSortButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            aiSortButton.heightAnchor.constraint(equalToConstant: 50),
            
            folderButton.topAnchor.constraint(equalTo: aiSortButton.bottomAnchor, constant: 12),
            folderButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            folderButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            folderButton.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: folderButton.bottomAnchor, constant: 12),
            saveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 8),
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadURL(from provider: NSItemProvider) {
        provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] item, _ in
            guard let self else { return }
            if let url = item as? URL {
                DispatchQueue.main.async {
                    self.sharedURL = url.absoluteString
                    self.urlLabel.text = self.sharedURL
                    self.fetchMetadata(for: url)
                    self.suggestFolder(for: url)
                }
            }
        }
    }

    private func loadText(from provider: NSItemProvider) {
        provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] item, _ in
            guard let self else { return }
            if let text = item as? String {
                DispatchQueue.main.async {
                    self.sharedText = text
                    self.urlLabel.text = text
                    self.previewImageView.image = UIImage(systemName: "note.text")
                }
            }
        }
    }

    private func loadImage(from provider: NSItemProvider) {
        provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { [weak self] item, _ in
            guard let self else { return }

            var image: UIImage?
            if let ui = item as? UIImage { image = ui }
            else if let url = item as? URL, let data = try? Data(contentsOf: url) { image = UIImage(data: data) }

            DispatchQueue.main.async {
                self.sharedImage = image
                self.previewImageView.image = image ?? UIImage(systemName: "photo")
                self.urlLabel.text = image != nil ? "Image" : "Image (unreadable)"
            }
        }
    }

    private func loadFileURL(from provider: NSItemProvider) {
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { [weak self] item, _ in
            guard let self else { return }
            if let url = item as? URL {
                DispatchQueue.main.async {
                    self.urlLabel.text = url.lastPathComponent
                    self.previewImageView.image = UIImage(systemName: "doc")
                    // stash it as text for now (we’ll copy it during save)
                    self.sharedText = url.absoluteString
                }
            }
        }
    }

    private func loadFileLike(from provider: NSItemProvider, uti: UTType) {
        provider.loadItem(forTypeIdentifier: uti.identifier, options: nil) { [weak self] item, _ in
            guard let self else { return }

            DispatchQueue.main.async {
                self.previewImageView.image = UIImage(systemName: "doc")
                self.urlLabel.text = uti == .message ? "Email" : "File"
                // We can only reliably persist this at save-time; keep a hint
                // If item is URL/Data we’ll handle it in saveBookmark()
            }
        }
    }
    
    private func extractSharedContent() {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let providers = item.attachments, !providers.isEmpty else { return }

        // Pick the “best” provider: URL > image > movie > file > text > data/message
        if let p = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
            loadURL(from: p); return
        }
        if let p = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }) {
            loadImage(from: p); return
        }
        if let p = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.movie.identifier) }) {
            loadFileLike(from: p, uti: .movie); return
        }
        if let p = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }) {
            loadFileURL(from: p); return
        }
        if let p = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.message.identifier) }) {
            loadFileLike(from: p, uti: .message); return
        }
        if let p = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.data.identifier) }) {
            loadFileLike(from: p, uti: .data); return
        }
        if let p = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) }) {
            loadText(from: p); return
        }
    }

    
    private func fetchMetadata(for url: URL) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            if self?.sharedImage == nil {
                self?.previewImageView.image = self?.generatePlaceholderImage(for: url)
            }
        }
    }
    
    private func generatePlaceholderImage(for url: URL) -> UIImage? {
        let size = CGSize(width: 400, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: colors as CFArray,
                                     locations: [0, 1])!
            context.cgContext.drawLinearGradient(gradient,
                                                start: .zero,
                                                end: CGPoint(x: size.width, y: size.height),
                                                options: [])
            
            let domain = url.host ?? "Link"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let textSize = domain.size(withAttributes: attributes)
            let textRect = CGRect(x: (size.width - textSize.width) / 2,
                                y: (size.height - textSize.height) / 2,
                                width: textSize.width,
                                height: textSize.height)
            domain.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    private func suggestFolder(for url: URL) {
        let urlString = url.absoluteString.lowercased()
        let host = url.host?.lowercased() ?? ""
        
        var suggestedFolderName = "Bookmarks"
        var icon = "folder.fill"
        
        if host.contains("youtube") || host.contains("vimeo") || host.contains("tiktok") {
            suggestedFolderName = "Videos to Watch"
            icon = "play.rectangle.fill"
        } else if host.contains("amazon") || host.contains("ebay") || urlString.contains("shop") {
            suggestedFolderName = "Buy Later"
            icon = "cart.fill"
        } else if host.contains("github") || host.contains("stackoverflow") ||
                  urlString.contains("tutorial") || urlString.contains("guide") {
            suggestedFolderName = "Learn to Code"
            icon = "chevron.left.forwardslash.chevron.right"
        } else if urlString.contains("article") || urlString.contains("blog") {
            suggestedFolderName = "Articles to Read"
            icon = "doc.text.fill"
        }
        
        var config = folderButton.configuration
        config?.title = suggestedFolderName
        config?.image = UIImage(systemName: icon)
        config?.baseForegroundColor = .systemBlue
        folderButton.configuration = config
    }
    
    @objc private func selectFolder() {
        let alert = UIAlertController(title: "Select Folder", message: nil, preferredStyle: .actionSheet)
        
        let folderNames = [
            ("Learn to Code", "chevron.left.forwardslash.chevron.right"),
            ("Buy Later", "cart.fill"),
            ("Videos to Watch", "play.rectangle.fill"),
            ("Startup Ideas", "lightbulb.fill"),
            ("Design Inspiration", "paintbrush.fill"),
            ("Articles to Read", "doc.text.fill")
        ]
        
        for (name, icon) in folderNames {
            let action = UIAlertAction(title: name, style: .default) { [weak self] _ in
                var config = self?.folderButton.configuration
                config?.title = name
                config?.image = UIImage(systemName: icon)
                self?.folderButton.configuration = config
            }
//            if #available(iOS 15.0, *) {
//                action.image = UIImage(systemName: icon)
//            }
            if let img = UIImage(systemName: icon) {
                action.setValue(img, forKey: "image")   // undocumented, but commonly used
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Create New Folder", style: .default) { [weak self] _ in
            self?.createNewFolder()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = folderButton
            popover.sourceRect = folderButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func createNewFolder() {
        let alert = UIAlertController(title: "New Folder", message: "Enter folder name", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Folder name"
        }
        
        alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            if let folderName = alert.textFields?.first?.text, !folderName.isEmpty {
                var config = self?.folderButton.configuration
                config?.title = folderName
                self?.folderButton.configuration = config
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func aiAutoSortAndSave() {
        guard let url = sharedURL, !url.isEmpty else {
            showError("Please share a valid URL for AI sorting")
            return
        }
        
        // Show loading state
        var config = aiSortButton.configuration
        config?.showsActivityIndicator = true
        config?.title = "AI Analyzing..."
        aiSortButton.configuration = config
        aiSortButton.isEnabled = false
        
        // Call the API to analyze and save
        Task {
            do {
                // Use TuckServerAPI to analyze and save bookmark with AI
                let baseURL = "https://tuckserverapi-production.up.railway.app"
                guard let apiURL = URL(string: "\(baseURL)/bookmarks/smart-save") else {
                    throw NSError(domain: "InvalidURL", code: 0)
                }
                
                var request = URLRequest(url: apiURL)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Get auth token from shared UserDefaults (App Group)
                if let sharedDefaults = UserDefaults(suiteName: "group.com.bookmarkapp.shared"),
                   let token = sharedDefaults.string(forKey: "authToken") {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                
                let title = extractTitle(from: url)
                let requestBody: [String: Any] = [
                    "url": url,
                    "title": title,
                    "notes": nil as Any?
                ]
                
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned \(httpResponse.statusCode): \(errorMessage)"])
                }
                
                // Save to pending store as well for immediate sync
                let payload = PendingBookmarkPayload(
                    kind: .url,
                    title: title,
                    folder: "AI Sorted",
                    typeRaw: determineBookmarkType(from: url).capitalized,
                    url: url
                )
                PendingStore.append(payload)
                
                DispatchQueue.main.async { [weak self] in
                    self?.showSuccess()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    var config = self?.aiSortButton.configuration
                    config?.showsActivityIndicator = false
                    config?.title = "AI Auto-Sort & Save"
                    self?.aiSortButton.configuration = config
                    self?.aiSortButton.isEnabled = true
                    self?.showError("AI sorting failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func saveBookmark() {
        let folderName = folderButton.configuration?.title ?? "Bookmarks"

        // Decide type (you can improve this logic later)
        let typeRaw: String = {
            if sharedImage != nil { return "Photo" }
            if let u = sharedURL { return determineBookmarkType(from: u).capitalized } // "Video" etc
            if sharedText != nil { return "Quote" }
            return "Other"
        }()

        // 1) URL share
        if let url = sharedURL, !url.isEmpty {
            let payload = PendingBookmarkPayload(
                kind: .url,
                title: extractTitle(from: url),
                folder: folderName,
                typeRaw: typeRaw,
                url: url
            )
            PendingStore.append(payload)
            showSuccess()
            return
        }

        // 2) Image share
        if let img = sharedImage {
            do {
                let asset = try SharedMediaStore.saveJPEG(image: img)
                let payload = PendingBookmarkPayload(
                    kind: .asset,
                    title: "Photo",
                    folder: folderName,
                    typeRaw: typeRaw,
                    assetRelativePath: asset.relativePath,
                    assetUTI: asset.uti,
                    assetFilename: asset.originalFilename
                )
                PendingStore.append(payload)
                showSuccess()
            } catch {
                showError("Failed to save image")
            }
            return
        }

        // 3) Plain text share
        if let text = sharedText, !text.isEmpty {
            let payload = PendingBookmarkPayload(
                kind: .text,
                title: "Text",
                folder: folderName,
                typeRaw: "Quote",
                text: text
            )
            PendingStore.append(payload)
            showSuccess()
            return
        }

        showError("Nothing to save")
    }

    
    private func extractTitle(from urlString: String) -> String {
        guard let url = URL(string: urlString) else { return urlString }
        
        if let host = url.host {
            return host.replacingOccurrences(of: "www.", with: "")
                      .replacingOccurrences(of: ".com", with: "")
                      .capitalized
        }
        
        return urlString
    }
    
    private func determineBookmarkType(from urlString: String) -> String {
        let lower = urlString.lowercased()
        
        if lower.contains("youtube") || lower.contains("vimeo") || lower.contains("tiktok") {
            return "video"
        } else if lower.contains("amazon") || lower.contains("shop") {
            return "product"
        } else if lower.contains("twitter") || lower.contains("tweet") {
            return "tweet"
        }
        
        return "article"
    }
    
    private func showSuccess() {
        let successView = UIView()
        successView.backgroundColor = .systemGreen
        successView.layer.cornerRadius = 12
        successView.translatesAutoresizingMaskIntoConstraints = false
        
        let checkmark = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkmark.tintColor = .white
        checkmark.contentMode = .scaleAspectFit
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Saved!"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        successView.addSubview(checkmark)
        successView.addSubview(label)
        view.addSubview(successView)
        
        NSLayoutConstraint.activate([
            successView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            successView.widthAnchor.constraint(equalToConstant: 200),
            successView.heightAnchor.constraint(equalToConstant: 100),
            
            checkmark.centerXAnchor.constraint(equalTo: successView.centerXAnchor),
            checkmark.topAnchor.constraint(equalTo: successView.topAnchor, constant: 20),
            checkmark.widthAnchor.constraint(equalToConstant: 40),
            checkmark.heightAnchor.constraint(equalToConstant: 40),
            
            label.centerXAnchor.constraint(equalTo: successView.centerXAnchor),
            label.topAnchor.constraint(equalTo: checkmark.bottomAnchor, constant: 8)
        ])
        
        // Animate and dismiss
        successView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            successView.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func cancel() {
        extensionContext?.cancelRequest(withError: NSError(domain: "com.bookmarkapp.share", code: 0))
    }
}
