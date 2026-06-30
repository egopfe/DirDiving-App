import SwiftUI

struct IOSApneaTrainingTablesView: View {
    @State private var co2Table = ApneaTrainingTableBuilder.buildCO2Table(
        .init(initialHoldSeconds: 90, initialRecoverySeconds: 120, recoveryDecrementSeconds: 15, repetitions: 8)
    )
    @State private var o2Table = ApneaTrainingTableBuilder.buildO2Table(
        .init(initialHoldSeconds: 60, holdIncrementSeconds: 15, fixedRecoverySeconds: 120, repetitions: 6)
    )
    @State private var disclaimerAcknowledged = false

    var body: some View {
        DIRScreenContainer {
            List {
                Section(DIRIOSLocalizer.string("apnea.training.co2_table")) {
                    ForEach(co2Table.steps.sorted(by: { $0.orderIndex < $1.orderIndex })) { step in
                        HStack {
                            Text(String(format: DIRIOSLocalizer.string("apnea.training.step"), step.orderIndex + 1))
                            Spacer()
                            Text("\(Formatters.time(step.holdSeconds)) / \(Formatters.time(step.recoverySeconds))")
                                .monospacedDigit()
                        }
                    }
                }

                Section(DIRIOSLocalizer.string("apnea.training.o2_table")) {
                    ForEach(o2Table.steps.sorted(by: { $0.orderIndex < $1.orderIndex })) { step in
                        HStack {
                            Text(String(format: DIRIOSLocalizer.string("apnea.training.step"), step.orderIndex + 1))
                            Spacer()
                            Text("\(Formatters.time(step.holdSeconds)) / \(Formatters.time(step.recoverySeconds))")
                                .monospacedDigit()
                        }
                    }
                }

                Section {
                    Toggle(DIRIOSLocalizer.string("apnea.training.disclaimer_ack"), isOn: $disclaimerAcknowledged)
                        .tint(DIRTheme.cyan)
                    Text(DIRIOSLocalizer.string("apnea.disclaimer.training_aid"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(DIRIOSLocalizer.string("apnea.training.title"))
    }
}
