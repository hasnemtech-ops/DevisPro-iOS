import UIKit
import WebKit

/// Devis Pro - application autonome (hors-ligne) basée sur une WKWebView.
/// Tout le contenu (HTML/CSS/JS) se trouve dans www/electricien-devis.html
/// et fonctionne entièrement sans connexion internet.
class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {

    var webView: WKWebView!
    private var openPanelCompletion: (([URL]?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0xF5/255, green: 0xF7/255, blue: 0xFA/255, alpha: 1)

        let contentController = WKUserContentController()
        contentController.add(self, name: "iosPrint")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        if let url = locateAppHTML() {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            // Filet de sécurité : si le fichier reste introuvable malgré toutes les
            // tentatives, on liste RÉCURSIVEMENT le contenu du paquet pour voir
            // exactement où il est passé (plutôt qu'un écran blanc silencieux).
            let bundlePath = Bundle.main.bundlePath
            var listing = "Introuvable malgré plusieurs emplacements testés.<br>Contenu complet du paquet :<br><br>"
            listing += recursiveListing(atPath: bundlePath, prefix: "")
            webView.loadHTMLString(
                "<html><body style='font-family:-apple-system;padding:30px;background:#FFEEEE;color:#C4432B;font-size:12px;'>" +
                "<h2>Erreur de chargement</h2><p>\(listing)</p></body></html>",
                baseURL: nil
            )
        }
    }

    /// Cherche electricien-devis.html à plusieurs emplacements possibles selon la façon
    /// dont Xcode/XcodeGen a effectivement copié les ressources dans le paquet final.
    private func locateAppHTML() -> URL? {
        // 1) Directement à la racine du paquet (cas attendu normalement)
        if let url = Bundle.main.url(forResource: "electricien-devis", withExtension: "html") {
            return url
        }
        // 2) Dans un sous-dossier "Resources" (si XcodeGen a préservé le dossier tel quel)
        if let url = Bundle.main.url(forResource: "electricien-devis", withExtension: "html", subdirectory: "Resources") {
            return url
        }
        // 3) Recherche récursive complète dans le paquet, en dernier recours
        let fileManager = FileManager.default
        if let enumerator = fileManager.enumerator(atPath: Bundle.main.bundlePath) {
            for case let path as String in enumerator {
                if path.hasSuffix("electricien-devis.html") {
                    return URL(fileURLWithPath: Bundle.main.bundlePath + "/" + path)
                }
            }
        }
        return nil
    }

    private func recursiveListing(atPath path: String, prefix: String, depth: Int = 0) -> String {
        guard depth < 4 else { return "" }
        guard let items = try? FileManager.default.contentsOfDirectory(atPath: path) else { return "" }
        var result = ""
        for item in items.sorted() {
            let fullPath = path + "/" + item
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir)
            result += "\(prefix)• \(item)\(isDir.boolValue ? "/" : "")<br>"
            if isDir.boolValue {
                result += recursiveListing(atPath: fullPath, prefix: prefix + "&nbsp;&nbsp;&nbsp;&nbsp;", depth: depth + 1)
            }
        }
        return result
    }

    // MARK: - Diagnostic : afficher toute erreur de chargement au lieu d'un écran blanc silencieux
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showLoadError(error)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showLoadError(error)
    }
    private func showLoadError(_ error: Error) {
        let message = error.localizedDescription.replacingOccurrences(of: "\"", with: "'")
        webView.loadHTMLString(
            "<html><body style='font-family:-apple-system;padding:40px;background:#FFEEEE;color:#C4432B;'>" +
            "<h2>Erreur de chargement</h2><p>\(message)</p></body></html>",
            baseURL: nil
        )
    }

    // MARK: - Pont JS -> natif pour l'impression (appelé par triggerPrint() dans la page)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "iosPrint" else { return }
        DispatchQueue.main.async {
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.outputType = .general
            printInfo.jobName = "Devis"

            let printController = UIPrintInteractionController.shared
            printController.printInfo = printInfo
            printController.printFormatter = self.webView.viewPrintFormatter()
            printController.present(animated: true, completionHandler: nil)
        }
    }

    // MARK: - Liens externes (WhatsApp, etc.) ouverts dans Safari plutôt que dans la WebView
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        if url.scheme == "file" {
            decisionHandler(.allow)
            return
        }
        if url.scheme == "https" || url.scheme == "http" {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    // Liens avec target="_blank" (ouverture de nouvelle fenêtre) -> ouvrir dans Safari aussi
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        return nil
    }

    // MARK: - Sélecteur de fichier natif (import du logo) pour <input type="file">
    @available(iOS 18.4, *)
    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        openPanelCompletion = completionHandler
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
}

// MARK: - Sélection d'image (logo)
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage,
           let data = image.jpegData(compressionQuality: 0.9) {
            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
            do {
                try data.write(to: tmpURL)
                openPanelCompletion?([tmpURL])
            } catch {
                openPanelCompletion?(nil)
            }
        } else {
            openPanelCompletion?(nil)
        }
        openPanelCompletion = nil
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        openPanelCompletion?(nil)
        openPanelCompletion = nil
    }
}
