import SwiftUI
import SavvyFoundation
import SavvyDesignSystem
import SavvyNetworking

struct SimulationListView: View {
    let deps: AppDependencies
    @State private var simulations: [SimulationEntry] = []
    @State private var showTemplatePicker = false
    @State private var selectedSimulation: SimulationEntry?

    var body: some View {
        NavigationStack {
            Group {
                if simulations.isEmpty {
                    VStack(spacing: SavvySpacing.lg) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Henuz simulasyon yok")
                            .font(.savvyTitleMedium)
                            .foregroundStyle(.secondary)
                        Text("\"Ne olur?\" senaryolarini kesfedin")
                            .font(.savvyBodySmall)
                            .foregroundStyle(.tertiary)
                        Button {
                            showTemplatePicker = true
                        } label: {
                            Label("Yeni Simulasyon", systemImage: "plus")
                                .font(.savvyTitleMedium)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: "1A56DB"))
                    }
                } else {
                    List {
                        ForEach(simulations) { sim in
                            NavigationLink {
                                SimulationDetailView(simulation: sim, deps: deps)
                            } label: {
                                simulationRow(sim)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task { try? await deps.simulationRepo.softDelete(id: sim.id) }
                                } label: { Label("Sil", systemImage: "trash") }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Simulasyon")
            .toolbar {
                if !simulations.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button { showTemplatePicker = true } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showTemplatePicker) {
                SimulationTemplatePickerView(deps: deps)
                    .presentationDetents([.large])
            }
            .task {
                for await items in deps.simulationRepo.watch() {
                    simulations = items
                }
            }
        }
    }

    @ViewBuilder
    private func simulationRow(_ sim: SimulationEntry) -> some View {
        HStack(spacing: SavvySpacing.md) {
            Image(systemName: sim.template?.sfSymbol ?? "sparkles")
                .font(.title3)
                .foregroundStyle(Color(hex: sim.colorHex))
                .frame(width: 44, height: 44)
                .background(Color(hex: sim.colorHex).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: SavvyRadius.sm))

            VStack(alignment: .leading, spacing: 2) {
                Text(sim.title).font(.savvyTitleMedium)
                if let desc = sim.description {
                    Text(desc)
                        .font(.savvyCaption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Text("\(sim.changes.count) degisiklik")
                    .font(.savvyCaption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if sim.isIncluded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.savvyIncome)
            }
        }
        .padding(.vertical, SavvySpacing.xs)
    }
}
