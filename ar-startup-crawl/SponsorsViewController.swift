//
//  SponsorsViewController.swift
//  ar-startup-crawl
//
//  Created by Andrew Beers on 7/18/18.
//  Copyright © 2018 Andrew Beers. All rights reserved.
//

import UIKit
import WebKit

class SponsorsViewController: UIViewController, WKNavigationDelegate {

    let screenSize: CGRect = UIScreen.main.bounds
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let width = screenSize.width
        let height = screenSize.height
        var frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        frame = CGRect(x: 0.0, y: view.safeAreaInsets.top , width: width, height: height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        
        
        webView = WKWebView(frame: frame, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        
        let fileName = "RED-26"
        guard let pdf = Bundle.main.url(forResource: fileName , withExtension: "pdf") else {
            return
        }
        
        let request = URLRequest(url: pdf)
        webView.load(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let webViewSubviews = self.getSubviewsOfView(v: self.webView)
        for v in webViewSubviews {
            if v.description.range(of:"WKPDFPageNumberIndicator") != nil {
                v.isHidden = true // hide page indicator in upper left
            }
        }
    }
    
    func getSubviewsOfView(v:UIView) -> [UIView] {
        var viewArray = [UIView]()
        for subview in v.subviews {
            viewArray += getSubviewsOfView(v: subview)
            viewArray.append(subview)
        }
        return viewArray
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
