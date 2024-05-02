import UIKit

final class EventVM {
    let event: Event
    let onEvent: (Event) -> Void

    init(
        _ event: Event,
        onEvent: @escaping (Event) -> Void
    ) {
        self.event = event
        self.onEvent = onEvent
    }
}
