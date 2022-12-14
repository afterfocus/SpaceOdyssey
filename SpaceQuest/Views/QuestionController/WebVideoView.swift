//
//  File.swift
//  SpaceQuest
//
//  Created by Максим Голов on 06.12.2020.
//

import WebKit

// MARK: - WebVideoView

/// Представление для отображения YouTube-видео
final class WebVideoView: UIView {
    
    // MARK: IBOutlets
    
    /// WebView для видео
    @IBOutlet weak var webView: WKWebView!
    /// View-закрывашка с индикатором загрузки и меткой
    @IBOutlet weak var coverView: UIView!
    /// Индикатор загрузки видео
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    /// Метка отсутствия видео
    @IBOutlet weak var noVideoLabel: UILabel!
    
    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        webView.layer.dropShadow(opacity: 0.35, radius: 7)
        webView.navigationDelegate = self
    }
    
    // MARK: - Internal Functions
    
    /// Загрузить страницу видео
    func loadVideo(url: URL) {
        coverView.isHidden = false
        loadingIndicator.isHidden = false
        noVideoLabel.isHidden = true
        loadingIndicator.startAnimating()
        webView.load(URLRequest(url: url))
    }
    
    /// Отобразить метку об отсутствии видео
    func showNoVideoLabel() {
        loadingIndicator.isHidden = true
        noVideoLabel.isHidden = false
    }
    
    /// Остановить воспроизведение видео
    func stopVideoPlaying() {
        webView.reload()
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
