import UIKit
import WebKit

class DynamicMultistepView: UIView {

    private let content: CGContent
    private var banner: CGBanner?
    private let typeId: String
    private let bannerId: String?

    // For MULTISTEP_3 expand/collapse
    private var isExpanded = false
    private var contentContainer: UIView?
    private var expandedHeight: CGFloat = 0
    private var collapsedHeight: CGFloat = 56

    init(frame: CGRect, content: CGContent, banner: CGBanner?, typeId: String, bannerId: String? = nil) {
        self.content = content
        self.banner = banner
        self.typeId = typeId
        self.bannerId = bannerId
        super.init(frame: frame)
        clipsToBounds = false
        setupCard()
        setupView()
        // If banner is nil (campaign data not loaded yet), listen for it
        if banner == nil {
            NotificationCenter.default.addObserver(self, selector: #selector(onCampaignsLoaded), name: Notification.Name("CG_CAMPAIGNS_LOADED"), object: nil)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("CG_CAMPAIGNS_LOADED"), object: nil)
    }

    @objc private func onCampaignsLoaded() {
        // Try to find the campaign now
        let campaignId = content.campaignId
        let campaign = CustomerGlu.campaignsAvailable?.campaigns?.first(where: { $0.campaignId == campaignId })
            ?? CustomerGlu.getInstance.loadCampaignResponse?.campaigns?.first(where: { $0.campaignId == campaignId })
        guard let foundBanner = campaign?.banner else { return }
        NSLog("[DynMS] Campaign loaded late, activityCount=%d, rebuilding", foundBanner.activityCount ?? -1)
        self.banner = foundBanner
        NotificationCenter.default.removeObserver(self, name: Notification.Name("CG_CAMPAIGNS_LOADED"), object: nil)
        // Rebuild the view
        subviews.forEach { $0.removeFromSuperview() }
        layer.sublayers?.filter { $0.name == "shine" }.forEach { $0.removeFromSuperlayer() }
        setupCard()
        setupView()
        // Update height
        let preferredH = DynamicMultistepView.preferredHeight(for: bounds.width, content: content, banner: foundBanner, typeId: typeId)
        if preferredH != bounds.height {
            frame.size.height = preferredH
            if let bid = bannerId {
                NotificationCenter.default.post(name: Notification.Name("CGBANNER_FINAL_HEIGHT"), object: nil, userInfo: [bid: Int(preferredH)])
            }
        }
    }

    // MARK: - Card Styling

    private var isDarkMode: Bool {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        }
        return false
    }

    private func setupCard() {
        let radius = CGFloat(ns?.cornerRadius ?? 12)
        let defaultBg: UIColor = isDarkMode ? UIColor(hex: "#1C1C1E") ?? .darkGray : .white
        backgroundColor = color(ns?.backgroundColor, defaultBg)
        layer.cornerRadius = radius
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = isDarkMode ? 0.3 : 0.12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.borderWidth = 0.5
        layer.borderColor = (isDarkMode ? UIColor(white: 0.3, alpha: 1) : UIColor(white: 0.88, alpha: 1)).cgColor
    }

    // Dark mode fallback colors
    private func defaultTitleColor() -> UIColor { isDarkMode ? .white : UIColor(hex: "#242220")! }
    private func defaultBodyColor() -> UIColor { isDarkMode ? UIColor(hex: "#CCCCCC")! : UIColor(hex: "#242220")! }
    private func defaultLockedColor() -> UIColor { isDarkMode ? UIColor(hex: "#666666")! : UIColor(hex: "#CCCCCC")! }

    // MARK: - Preferred Height (static, called before init)

    static func preferredHeight(for width: CGFloat, content: CGContent, banner: CGBanner?, typeId: String) -> CGFloat {
        let ws = WidgetStateSelector.select(from: content.widgetStates, banner: banner)
        guard ws != nil else { return 0 }
        var h: CGFloat = 0

        switch typeId {
        case "DYNAMIC_MULTISTEP_1":
            h = 16 // top
            if ws?.title != nil { h += 24 }
            if ws?.body != nil { h += 4 + 20 }
            h += 12 // gap before bar
            h += 20 // progress bar
            h += 16 // bottom

        case "DYNAMIC_MULTISTEP_2":
            h = 16
            if let img = ws?.headerImage, !img.isEmpty, img.hasPrefix("http") { h += 140 + 8 }
            if ws?.title != nil { h += 24 }
            h += 16 // gap after title
            h += 20 // progress bar
            h += 20 // gap after progress
            h += CGFloat(content.nativeStyle?.stepIconSize ?? 36) + 12 // circles + gap
            if ws?.ctaText != nil { h += 16 + 48 }
            h += 20

        case "DYNAMIC_MULTISTEP_3":
            h = 56

        default: h = 100
        }
        return max(h, 56)
    }

    // MARK: - Setup

    private func setupView() {
        guard let _ = content.widgetStates, !content.widgetStates!.isEmpty else {
            isHidden = true; return
        }
        switch typeId {
        case "DYNAMIC_MULTISTEP_1": buildMS1()
        case "DYNAMIC_MULTISTEP_2": buildMS2()
        case "DYNAMIC_MULTISTEP_3": buildMS3()
        default: break
        }
        addCloseButtonIfNeeded()
    }

    private func addCloseButtonIfNeeded() {
        guard let icon = content.closeIcon, !icon.isEmpty else { return }
        let size: CGFloat = 28
        let pad: CGFloat = 8
        let btn = UIButton(frame: CGRect(x: bounds.width - size - pad, y: pad, width: size, height: size))
        btn.layer.cornerRadius = size / 2
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        if icon.hasPrefix("http"), !icon.lowercased().hasSuffix(".svg") {
            let iv = UIImageView(frame: CGRect(x: 6, y: 6, width: size - 12, height: size - 12))
            iv.contentMode = .scaleAspectFit
            iv.tintColor = .gray
            iv.downloadImage(urlString: icon, success: { _ in }, failure: { _ in })
            btn.addSubview(iv)
        } else {
            btn.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn.tintColor = UIColor(hex: "#666666")
            btn.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        }
        addSubview(btn)
    }

    @objc private func closeTapped() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            self.isHidden = true
            // Notify RN to collapse height
            if let bid = self.bannerId {
                NotificationCenter.default.post(
                    name: Notification.Name("CGBANNER_FINAL_HEIGHT"),
                    object: nil, userInfo: [bid: 0]
                )
            }
        }
    }

    // MARK: - Data Helpers

    private var stepCompleted: Int { banner?.stepCompleted ?? 0 }
    private var activityCount: Int {
        if let c = banner?.activityCount, c > 0 { return c }
        if let states = content.widgetStates {
            let maxStep = states.compactMap({ $0.step }).max() ?? 0
            if maxStep > 0 { return maxStep + 1 }
            let distinct = Set(states.compactMap({ $0.step })).count
            if distinct > 1 { return distinct }
        }
        return 1
    }
    private var ws: CGWidgetState? { WidgetStateSelector.select(from: content.widgetStates, banner: banner) }
    private var ns: CGNativeStyle? { content.nativeStyle }

    // MARK: - Color Helper

    private func color(_ hex: String?, _ fallback: UIColor) -> UIColor {
        guard let h = hex else { return fallback }
        return UIColor(hex: h) ?? fallback
    }

    // Poppins-like system font (web SDK uses Poppins)
    private func titleFont(_ size: CGFloat) -> UIFont { .systemFont(ofSize: size, weight: .semibold) }
    private func bodyFont(_ size: CGFloat) -> UIFont { .systemFont(ofSize: size, weight: .regular) }

    // MARK: - ═══════════════ MS1: Compact Bar ═══════════════

    private func buildMS1() {
        guard let ws = ws else { return }
        let pad: CGFloat = 16
        let contentW = bounds.width - pad * 2 - 40 // 40 for right arrow icon
        var y: CGFloat = 16

        // Left side: title + body + progress bar
        // Title
        if let t = ws.title, !t.isEmpty {
            let lbl = UILabel(frame: CGRect(x: pad, y: y, width: contentW, height: 24))
            lbl.text = t
            lbl.font = titleFont(CGFloat(ns?.titleFontSize ?? 16))
            lbl.textColor = color(ns?.titleColor, defaultTitleColor())
            lbl.numberOfLines = 1
            addSubview(lbl)
            y = lbl.frame.maxY
        }

        // Body
        if let b = ws.body, !b.isEmpty {
            y += 4
            let lbl = UILabel(frame: CGRect(x: pad, y: y, width: contentW, height: 0))
            lbl.text = b
            lbl.font = bodyFont(CGFloat(ns?.bodyFontSize ?? 14))
            lbl.textColor = color(ns?.bodyColor, defaultBodyColor())
            lbl.numberOfLines = 2
            lbl.sizeToFit()
            lbl.frame.origin = CGPoint(x: pad, y: y)
            lbl.frame.size.width = contentW
            addSubview(lbl)
            y = lbl.frame.maxY
        }

        y += 12

        // Progress bar + reward text
        let rewardText = ws.progressMeter?.completedText
        let rewardW: CGFloat = rewardText != nil ? 50 : 0
        let barW = contentW - rewardW - (rewardText != nil ? 8 : 0)
        let barH: CGFloat = CGFloat(ns?.progressBarHeight ?? 16)

        let bar = MultistepProgressBarView(frame: CGRect(x: pad, y: y, width: barW, height: barH))
        bar.configure(stepCompleted: stepCompleted, activityCount: activityCount, nativeStyle: ns, progressBarIcon: content.progressBarIcon)
        addSubview(bar)

        if let rt = rewardText {
            let lbl = UILabel(frame: CGRect(x: bar.frame.maxX + 8, y: y, width: rewardW, height: barH))
            lbl.text = rt
            lbl.font = titleFont(16)
            lbl.textColor = color(ns?.brandColor, UIColor(hex: "#FF0099")!)
            addSubview(lbl)
        }

        // Right arrow icon (chevron right)
        let arrowSize: CGFloat = 24
        let arrowX = bounds.width - pad - arrowSize
        let arrowY = bounds.height / 2 - arrowSize / 2
        let arrow = UIImageView(frame: CGRect(x: arrowX, y: arrowY, width: arrowSize, height: arrowSize))
        arrow.image = UIImage(systemName: "chevron.right")
        arrow.tintColor = color(ns?.brandColor, UIColor(hex: "#FF0099")!)
        arrow.contentMode = .scaleAspectFit
        addSubview(arrow)
    }

    // MARK: - ═══════════════ MS2: Steps + Progress ═══════════════

    private func buildMS2() {
        guard let ws = ws else { return }
        let pad: CGFloat = 16
        let w = bounds.width - pad * 2
        var y: CGFloat = 0

        // Header image
        if let img = ws.headerImage, !img.isEmpty, img.hasPrefix("http") {
            let radius = CGFloat(ns?.cornerRadius ?? 12)
            if img.lowercased().hasSuffix(".svg") {
                // SVG: use WKWebView
                let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 140))
                webView.isOpaque = false
                webView.backgroundColor = .clear
                webView.scrollView.isScrollEnabled = false
                webView.scrollView.bounces = false
                let html = "<html><body style='margin:0;padding:0;overflow:hidden;background:transparent;'><img src='\(img)' style='width:100%;height:100%;object-fit:cover;border-radius:\(radius)px \(radius)px 0 0;' /></body></html>"
                webView.loadHTMLString(html, baseURL: nil)
                let mask = CAShapeLayer()
                mask.path = UIBezierPath(roundedRect: webView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath
                webView.layer.mask = mask
                addSubview(webView)
                y = webView.frame.maxY + 8
            } else {
                let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 140))
                iv.contentMode = .scaleAspectFill
                iv.clipsToBounds = true
                iv.backgroundColor = UIColor(hex: "#F0F0F0")
                let mask = CAShapeLayer()
                mask.path = UIBezierPath(roundedRect: iv.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath
                iv.layer.mask = mask
                iv.downloadImage(urlString: img, success: { [weak iv] _ in iv?.backgroundColor = .clear }, failure: { [weak iv] _ in iv?.isHidden = true })
                addSubview(iv)
                y = iv.frame.maxY + 8
            }
        }

        y += 16

        // Title
        if let t = ws.title, !t.isEmpty {
            let lbl = UILabel(frame: CGRect(x: pad, y: y, width: w, height: 24))
            lbl.text = t
            lbl.font = titleFont(CGFloat(ns?.titleFontSize ?? 16))
            lbl.textColor = color(ns?.titleColor, defaultTitleColor())
            lbl.numberOfLines = 0
            lbl.sizeToFit()
            lbl.frame = CGRect(x: pad, y: y, width: w, height: lbl.frame.height)
            addSubview(lbl)
            y = lbl.frame.maxY + 16
        }

        // Progress bar + reward
        let rewardText = ws.progressMeter?.completedText
        let rewardW: CGFloat = rewardText != nil ? 50 : 0
        let barW = w - rewardW - (rewardText != nil ? 8 : 0)
        let barH: CGFloat = CGFloat(ns?.progressBarHeight ?? 16)

        let bar = MultistepProgressBarView(frame: CGRect(x: pad, y: y, width: barW, height: barH))
        bar.configure(stepCompleted: stepCompleted, activityCount: activityCount, nativeStyle: ns, progressBarIcon: content.progressBarIcon)
        addSubview(bar)

        if let rt = rewardText {
            let lbl = UILabel(frame: CGRect(x: bar.frame.maxX + 8, y: y, width: rewardW, height: barH))
            lbl.text = rt
            lbl.font = titleFont(16)
            lbl.textColor = color(ns?.brandColor, UIColor(hex: "#FF0099")!)
            addSubview(lbl)
        }

        y = bar.frame.maxY + 20

        // Step circles
        let circlesH = buildStepCircles(in: self, y: y, width: bounds.width)
        y += circlesH + 8

        // CTA Button
        if let cta = ws.ctaText, !cta.isEmpty {
            y += 16
            let btn = makeCTA(text: cta, x: pad, y: y, width: w)
            addSubview(btn)
            addShine(to: btn)
        }
    }

    // MARK: - ═══════════════ MS3: Expandable Card ═══════════════

    private func buildMS3() {
        guard let ws = ws else { return }
        let pad: CGFloat = 16
        let headerH: CGFloat = 56

        // ── Header ──
        let header = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: headerH))
        header.backgroundColor = .clear
        addSubview(header)
        header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleExpand)))

        var labelX: CGFloat = pad

        // Badge
        if let badge = ws.badgeTag, !badge.isEmpty {
            let bv = makeBadge(text: badge)
            bv.frame.origin = CGPoint(x: pad, y: (headerH - bv.frame.height) / 2)
            header.addSubview(bv)
            labelX = bv.frame.maxX + 8
        }

        // Title
        let chevSize: CGFloat = 20
        if let t = ws.title, !t.isEmpty {
            let lbl = UILabel(frame: CGRect(x: labelX, y: 0, width: bounds.width - labelX - chevSize - pad * 2, height: headerH))
            lbl.text = t
            lbl.font = titleFont(CGFloat(ns?.titleFontSize ?? 16))
            lbl.textColor = color(ns?.titleColor, defaultTitleColor())
            header.addSubview(lbl)
        }

        // Chevron (animated rotation)
        let chev = UIImageView(frame: CGRect(x: bounds.width - pad - chevSize, y: (headerH - chevSize) / 2, width: chevSize, height: chevSize))
        chev.image = UIImage(systemName: "chevron.down")
        chev.tintColor = UIColor(hex: "#999999")
        chev.contentMode = .scaleAspectFit
        chev.tag = 999
        header.addSubview(chev)

        // Thin separator
        let sep = UIView(frame: CGRect(x: pad, y: headerH - 0.5, width: bounds.width - pad * 2, height: 0.5))
        sep.backgroundColor = UIColor(hex: "#E5E5E5")
        addSubview(sep)

        // ── Expandable content ──
        let container = UIView(frame: CGRect(x: 0, y: headerH, width: bounds.width, height: 0))
        container.clipsToBounds = true
        addSubview(container)
        contentContainer = container

        var y: CGFloat = 12

        // Step circles (compact)
        let circlesH = buildStepCircles(in: container, y: y, width: bounds.width)
        y += circlesH + 4

        // Body
        if let b = ws.body, !b.isEmpty {
            let lbl = UILabel(frame: CGRect(x: pad, y: y, width: bounds.width - pad * 2, height: 0))
            lbl.text = b
            lbl.font = bodyFont(CGFloat(ns?.bodyFontSize ?? 14))
            lbl.textColor = color(ns?.bodyColor, defaultBodyColor())
            lbl.numberOfLines = 0
            lbl.sizeToFit()
            lbl.frame = CGRect(x: pad, y: y, width: bounds.width - pad * 2, height: lbl.frame.height)
            container.addSubview(lbl)
            y = lbl.frame.maxY + 12
        }

        // CTA
        if let cta = ws.ctaText, !cta.isEmpty {
            let btn = makeCTA(text: cta, x: pad, y: y, width: bounds.width - pad * 2)
            container.addSubview(btn)
            addShine(to: btn)
            y = btn.frame.maxY + 16
        }

        expandedHeight = y
    }

    // MARK: - ═══════════════ Shared Components ═══════════════

    // Step circles (horizontally scrollable)
    /// Get the progressRewardText for a step index (shown inside circle, e.g. "$2", "$4")
    private func stepLabel(for index: Int) -> String {
        if let states = content.widgetStates {
            for ws in states {
                if ws.step == index, let pb = ws.progressBar, let lbl = pb.progressRewardText, !lbl.isEmpty {
                    return lbl
                }
            }
        }
        return "\(index + 1)"
    }

    private func buildStepCircles(in parent: UIView, y: CGFloat, width: CGFloat) -> CGFloat {
        let count = activityCount
        let pad: CGFloat = 16
        let baseSize = CGFloat(ns?.stepIconSize ?? 36)
        let gap: CGFloat = 12

        // Fit circles to width, min 24pt
        let available = width - pad * 2
        let needed = CGFloat(count) * baseSize + CGFloat(max(count - 1, 0)) * gap
        let size = min(baseSize, max(24, needed > available ? (available - CGFloat(max(count-1,0)) * gap) / CGFloat(count) : baseSize))

        let totalW = CGFloat(count) * size + CGFloat(max(count - 1, 0)) * gap
        let needsScroll = totalW > width - pad * 2

        let sv = UIScrollView(frame: CGRect(x: 0, y: y, width: width, height: size + 4))
        sv.showsHorizontalScrollIndicator = false
        sv.contentSize = CGSize(width: needsScroll ? totalW + pad * 2 : width, height: size + 4)
        parent.addSubview(sv)

        let startX: CGFloat = needsScroll ? pad : (width - totalW) / 2
        var x = startX

        let completedCol = color(ns?.completedStepColor, UIColor(hex: "#FF0099")!)
        let currentCol = color(ns?.currentStepColor, UIColor(hex: "#FF0099")!)
        let lockedCol = color(ns?.lockedStepColor, defaultLockedColor())

        for i in 0..<count {
            if i > 0 {
                // Connector
                let cw = gap
                let ch: CGFloat = 3
                let conn = UIView(frame: CGRect(x: x, y: size / 2 - ch / 2, width: cw, height: ch))
                conn.backgroundColor = i <= stepCompleted ? completedCol : UIColor(hex: "#E5E5E5") ?? .lightGray
                conn.layer.cornerRadius = ch / 2
                sv.addSubview(conn)
                x += cw
            }

            let circle = UIView(frame: CGRect(x: x, y: 0, width: size, height: size))
            circle.layer.cornerRadius = size / 2
            circle.clipsToBounds = true

            if i < stepCompleted {
                // ✅ Completed
                circle.backgroundColor = completedCol
                let iconSize = size * 0.45
                let check = UIImageView(frame: CGRect(x: (size - iconSize) / 2, y: (size - iconSize) / 2, width: iconSize, height: iconSize))
                if let url = content.progressMeterIcon, !url.isEmpty, !url.hasSuffix(".svg") {
                    check.downloadImage(urlString: url, success: { _ in }, failure: { _ in })
                } else {
                    check.image = UIImage(systemName: "checkmark")
                    check.tintColor = .white
                }
                check.contentMode = .scaleAspectFit
                circle.addSubview(check)
            } else if i == stepCompleted {
                // 🔵 Current
                circle.backgroundColor = .white
                circle.layer.borderColor = currentCol.cgColor
                circle.layer.borderWidth = 2.5
                let lbl = UILabel(frame: circle.bounds.insetBy(dx: 2, dy: 2))
                lbl.text = stepLabel(for: i)
                lbl.font = .systemFont(ofSize: min(size * 0.22, 10), weight: .bold)
                lbl.textAlignment = .center
                lbl.numberOfLines = 2
                lbl.adjustsFontSizeToFitWidth = true
                lbl.minimumScaleFactor = 0.6
                lbl.textColor = currentCol
                circle.addSubview(lbl)
            } else {
                // 🔒 Locked
                circle.backgroundColor = isDarkMode ? UIColor(hex: "#2C2C2E") ?? .darkGray : UIColor(hex: "#F5F5F5") ?? UIColor(white: 0.96, alpha: 1)
                circle.layer.borderColor = lockedCol.withAlphaComponent(0.4).cgColor
                circle.layer.borderWidth = 1.5
                let lbl = UILabel(frame: circle.bounds.insetBy(dx: 2, dy: 2))
                lbl.text = stepLabel(for: i)
                lbl.font = .systemFont(ofSize: min(size * 0.20, 9), weight: .medium)
                lbl.textAlignment = .center
                lbl.numberOfLines = 2
                lbl.adjustsFontSizeToFitWidth = true
                lbl.minimumScaleFactor = 0.6
                lbl.textColor = lockedCol
                circle.addSubview(lbl)
            }

            sv.addSubview(circle)
            x += size
        }

        // Auto-scroll to current step
        if needsScroll && stepCompleted > 0 {
            let scrollTo = startX + CGFloat(stepCompleted) * (size + gap) - width / 2
            sv.setContentOffset(CGPoint(x: max(0, min(scrollTo, sv.contentSize.width - width)), y: 0), animated: false)
        }

        return size + 4
    }

    // CTA Button
    private func makeCTA(text: String, x: CGFloat, y: CGFloat, width: CGFloat) -> UIButton {
        let btn = UIButton(frame: CGRect(x: x, y: y, width: width, height: 48))
        btn.setTitle(text, for: .normal)
        btn.setTitleColor(color(ns?.ctaTextColor, .white), for: .normal)
        btn.backgroundColor = color(ns?.ctaBackgroundColor, UIColor(hex: "#4F4DF8")!)
        btn.layer.cornerRadius = CGFloat(ns?.ctaBorderRadius ?? ns?.cornerRadius ?? 12)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)
        return btn
    }

    @objc private func ctaTapped() {
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        // Delegate to parent BannerView's tap handler
        if let bannerView = findParent(ofType: BannerView.self) {
            bannerView.performButtonAction()
        }
    }

    private func findParent<T: UIView>(ofType type: T.Type) -> T? {
        var current = superview
        while let parent = current {
            if let match = parent as? T { return match }
            current = parent.superview
        }
        return nil
    }

    // Badge pill
    private func makeBadge(text: String) -> UIView {
        let brandCol = color(ns?.brandColor, UIColor(hex: "#E00087")!)
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: CGFloat(ns?.badgeFontSize ?? 11), weight: .bold)
        lbl.textColor = brandCol
        lbl.sizeToFit()
        let h: CGFloat = 24
        let w = lbl.frame.width + 16
        let v = UIView(frame: CGRect(x: 0, y: 0, width: w, height: h))
        v.backgroundColor = brandCol.withAlphaComponent(0.1)
        v.layer.cornerRadius = h / 2
        v.layer.borderColor = brandCol.withAlphaComponent(0.3).cgColor
        v.layer.borderWidth = 1
        lbl.frame = CGRect(x: 8, y: (h - lbl.frame.height) / 2, width: lbl.frame.width, height: lbl.frame.height)
        v.addSubview(lbl)
        return v
    }

    // MARK: - Expand/Collapse (MS3)

    @objc private func toggleExpand() {
        guard let container = contentContainer else { return }
        isExpanded.toggle()
        let target: CGFloat = isExpanded ? expandedHeight : 0
        let newTotalHeight = collapsedHeight + target

        if let header = subviews.first, let chev = header.viewWithTag(999) as? UIImageView {
            UIView.animate(withDuration: 0.25) {
                chev.transform = self.isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            }
        }

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: .curveEaseInOut) {
            container.frame.size.height = target
            self.frame.size.height = newTotalHeight
            // Resize parent BannerView scroll view
            if let scrollView = self.superview as? UIScrollView {
                scrollView.contentSize.height = newTotalHeight
            }
            // Resize parent BannerView
            if let bannerView = self.findParent(ofType: BannerView.self) {
                bannerView.frame.size.height = newTotalHeight
                bannerView.constraints.filter { $0.firstAttribute == .height }.forEach { $0.constant = newTotalHeight }
            }
        } completion: { _ in
            // Post height change to RN bridge
            if let bid = self.bannerId {
                let postInfo: [String: Any] = [bid: Int(newTotalHeight)]
                NotificationCenter.default.post(
                    name: Notification.Name("CGBANNER_FINAL_HEIGHT"),
                    object: nil, userInfo: postInfo
                )
            }
        }
    }

    // MARK: - Shine Animation (CTA)

    private func addShine(to button: UIButton) {
        let shine = CAGradientLayer()
        shine.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        shine.locations = [0, 0.5, 1]
        shine.startPoint = CGPoint(x: 0, y: 0.5)
        shine.endPoint = CGPoint(x: 1, y: 0.5)
        shine.frame = CGRect(x: -button.bounds.width, y: 0, width: button.bounds.width * 0.4, height: button.bounds.height)
        button.layer.addSublayer(shine)

        let anim = CABasicAnimation(keyPath: "position.x")
        anim.fromValue = -button.bounds.width * 0.2
        anim.toValue = button.bounds.width * 1.2
        anim.duration = 2.5
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        shine.add(anim, forKey: "shine")
    }
}
