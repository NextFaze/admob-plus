class AMSBanner: AMSAdBase, GADBannerViewDelegate {
    var bannerView: GADBannerView!
    var adSize: GADAdSize!
    var position: String!

    var bannerBottomConstraint: NSLayoutConstraint!
    var bannerCenterConstraint: NSLayoutConstraint!
    
    var view: UIView {
        return self.plugin.viewController.view
    }

    init(id: Int, adUnitID: String, adSize: GADAdSize, position: String) {
        super.init(id: id, adUnitID: adUnitID)

        self.adSize = adSize
        self.position = position
    }

    deinit {
        bannerView = nil
    }

    func show(request: GADRequest) {
        if bannerView != nil {
            bannerView.isHidden = false
        } else {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            addBannerViewToView(bannerView)
            bannerView.rootViewController = plugin.viewController
        }
        bannerView.delegate = self

        bannerView.adUnitID = adUnitID
        bannerView.load(request)
    }

    func hide() {
        if (bannerView?.superview) != nil {
            bannerView.delegate = nil
            bannerView.rootViewController = nil
            bannerView.removeFromSuperview()
            bannerView = nil
            view.removeConstraints([
                self.bannerBottomConstraint,
                self.bannerCenterConstraint
            ]);
            self.resizeWebView()
        }
    }

    func addBannerViewToView(_ bannerView: UIView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black
        view.addSubview(bannerView)
        self.bannerBottomConstraint = NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: plugin.viewController.bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0)
        self.bannerCenterConstraint = NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        view.addConstraints([
            self.bannerBottomConstraint,
            self.bannerCenterConstraint
        ])
        self.resizeWebView()
    }

    @available (iOS 11, *)
    func positionBannerInSafeArea(_ bannerView: UIView) {
        let guide: UILayoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate(
            [
                guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
                guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
                guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
            ]
        )
    }

    func positionBanner(_ bannerView: UIView) {
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        if position == "top" {
            view.addConstraint(NSLayoutConstraint(item: bannerView,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: plugin.viewController.topLayoutGuide,
                                                  attribute: .top,
                                                  multiplier: 1,
                                                  constant: 0))
        } else {
            view.addConstraint(NSLayoutConstraint(item: bannerView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: plugin.viewController.bottomLayoutGuide,
                                                  attribute: .top,
                                                  multiplier: 1,
                                                  constant: 0))
        }
    }
    
    func resizeWebView() {
        var frame = view.frame
        if bannerView != nil {
            if position == "top" {
                frame.origin.y += bannerView.frame.height
                if #available(iOS 11.0, *) {
                    frame.origin.y += self.plugin.webView.safeAreaInsets.top
                }
            }
            frame.size.height -= bannerView.frame.height
            if #available(iOS 11.0, *) {
                frame.size.height -= self.plugin.webView.safeAreaInsets.bottom
            }
        }
        self.plugin.webView.frame = frame
    }

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        plugin.emit(eventType: AMSEvents.bannerLoad)
    }

    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        plugin.emit(eventType: AMSEvents.bannerLoadFail)
    }

    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        plugin.emit(eventType: AMSEvents.bannerOpen)
    }

    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
    }

    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        plugin.emit(eventType: AMSEvents.bannerClose)
    }

    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        plugin.emit(eventType: AMSEvents.bannerExitApp)
    }
}
