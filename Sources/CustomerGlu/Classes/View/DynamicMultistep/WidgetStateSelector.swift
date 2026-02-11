import Foundation

struct WidgetStateSelector {
    static func select(from widgetStates: [CGWidgetState]?, banner: CGBanner?) -> CGWidgetState? {
        guard let states = widgetStates, !states.isEmpty else { return nil }
        guard let banner = banner else { return states.first }

        let status = banner.userCampaignStatus ?? "pristine"
        let step = banner.stepCompleted ?? 0

        // 1. If completed, find completed state
        if status == "completed" {
            if let found = states.first(where: { $0.state == "completed" }) {
                return found
            }
        }

        // 2. Match step + status
        if let found = states.first(where: { $0.step == step && $0.state == status }) {
            return found
        }

        // 3. Fallback: match step + "in-progress"
        if let found = states.first(where: { $0.step == step && $0.state == "in-progress" }) {
            return found
        }

        // 4. Final fallback
        return states.first
    }
}
