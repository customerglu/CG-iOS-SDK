import Foundation

public struct CGNativeStyle: Codable {
    var brandColor: String?
    var backgroundColor: String?
    var titleColor: String?
    var bodyColor: String?
    var progressTrackColor: String?
    var progressFillColor: String?
    var progressInProgressColor: String?
    var ctaBackgroundColor: String?
    var ctaTextColor: String?
    var cornerRadius: Double?
    var progressBarHeight: Double?
    var stepIconSize: Double?
    var completedStepColor: String?
    var lockedStepColor: String?
    var currentStepColor: String?
    var titleFontSize: Double?
    var bodyFontSize: Double?
    var badgeFontSize: Double?

    init(fromDictionary dictionary: [String: Any]) {
        brandColor = dictionary["brandColor"] as? String
        backgroundColor = dictionary["backgroundColor"] as? String
        titleColor = dictionary["titleColor"] as? String
        bodyColor = dictionary["bodyColor"] as? String
        progressTrackColor = dictionary["progressTrackColor"] as? String
        progressFillColor = dictionary["progressFillColor"] as? String
        progressInProgressColor = dictionary["progressInProgressColor"] as? String
        ctaBackgroundColor = dictionary["ctaBackgroundColor"] as? String
        ctaTextColor = dictionary["ctaTextColor"] as? String
        cornerRadius = dictionary["cornerRadius"] as? Double
        progressBarHeight = dictionary["progressBarHeight"] as? Double
        stepIconSize = dictionary["stepIconSize"] as? Double
        completedStepColor = dictionary["completedStepColor"] as? String
        lockedStepColor = dictionary["lockedStepColor"] as? String
        currentStepColor = dictionary["currentStepColor"] as? String
        titleFontSize = dictionary["titleFontSize"] as? Double
        bodyFontSize = dictionary["bodyFontSize"] as? Double
        badgeFontSize = dictionary["badgeFontSize"] as? Double
    }

    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if let brandColor = brandColor { dictionary["brandColor"] = brandColor }
        if let backgroundColor = backgroundColor { dictionary["backgroundColor"] = backgroundColor }
        if let titleColor = titleColor { dictionary["titleColor"] = titleColor }
        if let bodyColor = bodyColor { dictionary["bodyColor"] = bodyColor }
        if let progressTrackColor = progressTrackColor { dictionary["progressTrackColor"] = progressTrackColor }
        if let progressFillColor = progressFillColor { dictionary["progressFillColor"] = progressFillColor }
        if let progressInProgressColor = progressInProgressColor { dictionary["progressInProgressColor"] = progressInProgressColor }
        if let ctaBackgroundColor = ctaBackgroundColor { dictionary["ctaBackgroundColor"] = ctaBackgroundColor }
        if let ctaTextColor = ctaTextColor { dictionary["ctaTextColor"] = ctaTextColor }
        if let cornerRadius = cornerRadius { dictionary["cornerRadius"] = cornerRadius }
        if let progressBarHeight = progressBarHeight { dictionary["progressBarHeight"] = progressBarHeight }
        if let stepIconSize = stepIconSize { dictionary["stepIconSize"] = stepIconSize }
        if let completedStepColor = completedStepColor { dictionary["completedStepColor"] = completedStepColor }
        if let lockedStepColor = lockedStepColor { dictionary["lockedStepColor"] = lockedStepColor }
        if let currentStepColor = currentStepColor { dictionary["currentStepColor"] = currentStepColor }
        if let titleFontSize = titleFontSize { dictionary["titleFontSize"] = titleFontSize }
        if let bodyFontSize = bodyFontSize { dictionary["bodyFontSize"] = bodyFontSize }
        if let badgeFontSize = badgeFontSize { dictionary["badgeFontSize"] = badgeFontSize }
        return dictionary
    }
}
