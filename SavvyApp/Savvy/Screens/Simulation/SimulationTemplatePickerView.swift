import SwiftUI
import SavvyFoundation
import SavvyDesignSystem
import SavvyNetworking

struct SimulationTemplatePickerView: View {
    let deps: AppDependencies
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTemplate: SimulationTemplate?

    var body: some View {
        NavigationStack {
            List {
                ForEach(SimulationTemplate.allCases) { template in
                    Button {
                        createSimulation(template: template)
                    } label: {
                        HStack(spacing: SavvySpacing.md) {
                            Image(systemName: template.sfSymbol)
                                .font(.title2)
                                .foregroundStyle(Color(hex: template.colorHex))
                                .frame(width: 44, height: 44)
                                .background(Color(hex: template.colorHex).opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: SavvyRadius.sm))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(template.label)
                                    .font(.savvyTitleMedium)
                                    .foregroundStyle(.primary)
                                Text(template.subtitle)
                                    .font(.savvyCaption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, SavvySpacing.xs)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Senaryo Sec")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Iptal") { dismiss() }
                }
            }
        }
    }

    private func createSimulation(template: SimulationTemplate) {
        let entry = SimulationEntry(
            title: template.label,
            template: template,
            iconName: template.sfSymbol,
            colorHex: template.colorHex
        )
        Task {
            try? await deps.simulationRepo.add(entry)
            dismiss()
        }
    }
}
