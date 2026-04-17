import WidgetKit
import SwiftUI

@main
struct SavvyWidgetBundle: WidgetBundle {
    var body: some Widget {
        BalanceSummaryWidget()
        MonthlyOverviewWidget()
    }
}
