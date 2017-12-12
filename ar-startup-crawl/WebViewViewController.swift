//
//  WebViewViewController.swift
//  AR Startup Crawl
//
//  Created by Andrew Beers on 10/27/17.
//  Copyright © 2017 Andrew Beers. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {

    var address: String!
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize = UIScreen.main.bounds
        let width = screenSize.width
        let height = screenSize.height
        
        let frame = CGRect(x: 0.0, y: view.safeAreaInsets.top , width: width, height: height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        webView = WKWebView(frame: frame)
        view = webView
        guard let url: URL = URL(string: address) else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
