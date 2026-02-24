import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.teal.opacity(0.3), .cyan.opacity(0.2), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.teal.opacity(0.2), lineWidth: 20)
                        .frame(width: 160, height: 160)

                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(
                            LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(colors: [.teal, .cyan], startPoint: .top, endPoint: .bottom)
                        )
                }

                VStack(spacing: 12) {
                    Text("Energy Tracker")
                        .font(.largeTitle.bold())

                    Text("Understand your energy patterns")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    showOnboarding = true
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingSheetView()
        }
    }
}

struct OnboardingSheetView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("userName") private var userName = ""
    @AppStorage("energyGoal") private var energyGoal = 7

    @State private var step = 0
    @State private var nameInput = ""
    @State private var goalInput = 7

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(index <= step ?
                                AnyShapeStyle(LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)) :
                                AnyShapeStyle(Color(.systemGray4))
                            )
                            .frame(width: index == step ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: step)
                    }
                }
                .padding(.top, 16)

                Spacer()

                Group {
                    switch step {
                    case 0:
                        nameStep
                    case 1:
                        goalStep
                    default:
                        readyStep
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                Spacer()

                Button {
                    advance()
                } label: {
                    Text(step == 2 ? "Let's Go" : "Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled()
    }

    private var nameStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.fill")
                .font(.system(size: 48))
                .foregroundStyle(.teal)

            Text("What's your name?")
                .font(.title2.bold())

            TextField("Your name", text: $nameInput)
                .textFieldStyle(.plain)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 40)
        }
    }

    private var goalStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundStyle(.cyan)

            Text("Set your energy goal")
                .font(.title2.bold())

            Text("What energy level do you aim for daily?")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("\(goalInput)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)
                )
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: goalInput)

            Slider(value: Binding(
                get: { Double(goalInput) },
                set: { goalInput = Int($0) }
            ), in: 1...10, step: 1)
            .tint(.teal)
            .padding(.horizontal, 40)
        }
    }

    private var readyStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.teal)

            Text("You're all set!")
                .font(.title2.bold())

            Text("Start tracking your energy and discover your patterns.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func advance() {
        if step == 0 {
            userName = nameInput.trimmingCharacters(in: .whitespaces)
        }

        if step == 1 {
            energyGoal = goalInput
        }

        if step < 2 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                step += 1
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                hasCompletedOnboarding = true
            }
        }
    }
}

#Preview {
    OnboardingView()
}
