//
//  File.swift
//  SpaceQuest
//
//  Created by Максим Голов on 06.12.2020.
//

import WebKit

// MARK: - WebVideoView

/// Представление для отображения YouTube-видео
class WebVideoView: UIView {
    /// WebView для видео
    @IBOutlet weak var webView: WKWebView!
    /// View-закрывашка с индикатором загрузки и меткой
    @IBOutlet weak var coverView: UIView!
    /// Индикатор загрузки видео
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    /// Метка отсутствия видео
    @IBOutlet weak var noVideoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        webView.layer.dropShadow(opacity: 0.35, radius: 7)
        webView.navigationDelegate = self
    }
    
    /// Загрузить страницу видео
    func loadVideo(url: URL) {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        webView.load(URLRequest(url: url))
    }
    
    /// Отобразить метку об отсутствии видео
    func showNoVideoLabel() {
        loadingIndicator.isHidden = true
        noVideoLabel.isHidden = false
    }
}

// MARK: - WKNavigationDelegate

extension WebVideoView: WKNavigationDelegate {
    /// Завершена загрузка страницы с видео
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        coverView.isHidden = true
        loadingIndicator.stopAnimating()
    }
}
