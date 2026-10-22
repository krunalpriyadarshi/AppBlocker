import SwiftUI
import WebKit

struct WebBrowserView: UIViewRepresentable {
    
    let url: URL
    static let dataStore = WKWebsiteDataStore.default()
    
    let networkBlockScript = """
        (function() {
            var originalOpen = XMLHttpRequest.prototype.open;
            var originalSend = XMLHttpRequest.prototype.send;

            XMLHttpRequest.prototype.open = function(method, url) {
                this._url = url;
                return originalOpen.apply(this, arguments);
            };

            XMLHttpRequest.prototype.send = function() {
                if (this._url && shouldBlock(this._url)) {
                    return;
                }
                return originalSend.apply(this, arguments);
            };

            var originalFetch = window.fetch;
            window.fetch = function(resource, options) {
                var url = (resource && resource.url) ? resource.url : resource;
                url = url ? url.toString() : '';

                if (shouldBlock(url)) {
                    return Promise.resolve(
                        new Response(
                            JSON.stringify({items: [], status: 'ok'}),
                            {
                                status: 200,
                                headers: {'Content-Type': 'application/json'}
                            }
                        )
                    );
                }
                return originalFetch.apply(this, arguments);
            };

            function shouldBlock(url) {
                var blockedPatterns = [
                    '/api/v1/ads/',
                    '/api/v1/feed/ads',
                    '/ads/graphql',
                    'ads_manager',
                    '/api/v1/ad_tracking',
                    'ad_platform',
                    'promoted_content',
                    'paid_partnership',
                    'adserver',
                    'graph.facebook.com/v',
                    'pixel.facebook.com',
                    'an.facebook.com',
                    'connect.facebook.net/en_US/fbevents',
                    'connect.facebook.net/signals',
                    'facebook.com/tr/',
                    'doubleclick.net',
                    'googlesyndication.com',
                    'googletagmanager.com',
                    'googletagservices.com',
                    'adservice.google.com',
                    'pagead2.googlesyndication.com',
                    'adnxs.com',
                    'moatads.com',
                    'criteo.com',
                    'rubiconproject.com',
                    'openx.net',
                    'pubmatic.com'
                ];
                return blockedPatterns.some(function(pattern) {
                    return url.includes(pattern);
                });
            }
        })();
    """
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let script = WKUserScript(
            source: networkBlockScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        let contentController = WKUserContentController()
        contentController.addUserScript(script)

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = WebBrowserView.dataStore

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.scrollView.bounces = true
        webView.backgroundColor = .white
        webView.isOpaque = true
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url == nil {
            let request = URLRequest(
                url: url,
                cachePolicy: .returnCacheDataElseLoad,
                timeoutInterval: 30
            )
            webView.load(request)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            let url = navigationAction.request.url?.absoluteString ?? ""
            let blockedDomains = [
                "doubleclick.net",
                "googlesyndication.com",
                "googletagmanager.com",
                "adservice.google.com",
                "pixel.facebook.com",
                "an.facebook.com",
                "connect.facebook.net",
                "pagead2.googlesyndication.com",
                "adnxs.com",
                "criteo.com",
                "moatads.com"
            ]
            if blockedDomains.contains(where: { url.contains($0) }) {
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}
