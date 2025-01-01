import SwiftUI

struct Serpentine: Identifiable {
    let id = UUID()
    var offset: CGSize
    var color: Color
    var waveAmplitude: CGFloat
    var waveFrequency: Double // New property for wave frequency
    var fallSpeed: Double
    var startTime: Double
}


struct ContentView: View {
    @State private var timerValue: Int = 0
    @State private var timer: Timer? = nil
    @State private var buttonClicked: Bool = false
    @State private var longEffect: Bool = false
    @State private var serpentines: [Serpentine] = []
    @State private var textScaled: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Text(formatTime(from: timerValue))
                        .font(.system(size: 72, weight: .bold, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .scaleEffect(textScaled ? 2.5 : 1.0) // Apply scale effect
                        .animation(.easeInOut(duration: 0.3), value: textScaled) // Smooth animation

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            buttonClicked = true
                        }
                        withAnimation(.easeInOut(duration: 1.0)) {
                            longEffect = true
                        }

                        // Trigger the text scale effect
                        textScaled = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            textScaled = false
                        }

                        // Trigger the first explosion
                        triggerSerpentineExplosion(
                            screenWidth: geometry.size.width,
                            screenHeight: geometry.size.height
                        )

                        // Schedule ten more explosions at 0.1-second intervals
                        for i in 1...40 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                triggerSerpentineExplosion(
                                    screenWidth: geometry.size.width,
                                    screenHeight: geometry.size.height
                                )
                            }
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            buttonClicked = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            longEffect = false
                        }

                        startOrResetTimer()
                    }) {
                        Text("Start")
                            .font(.system(size: 24, weight: .bold))
                            .padding()
                            .frame(maxWidth: 200)
                            .background(
                                buttonClicked ? Color.green : (longEffect ? Color.blue.opacity(0.5) : Color.blue)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .scaleEffect(buttonClicked ? 1.2 : 1.0)
                    }
                    .padding()
                }

                // Serpentines layer
                ForEach(serpentines) { serpentine in
                    Rectangle()
                        .fill(serpentine.color)
                        .frame(width: 10, height: 40)
                        .offset(serpentine.offset)
                        .onAppear {
                            animateSerpentine(serpentine, screenHeight: geometry.size.height)
                        }
                }
            }
            .frame(minWidth: 400, minHeight: 300)
        }
    }

    private func startOrResetTimer() {
        timer?.invalidate()
        timerValue = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timerValue += 1
        }
    }

    private func formatTime(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }

    private func triggerSerpentineExplosion(screenWidth: CGFloat, screenHeight: CGFloat) {
        let colors: [Color] = [.red, .green, .blue, .yellow, .purple, .orange]
        let newSerpentines = (1...30).map { _ in
            Serpentine(
                offset: CGSize(
                    width: CGFloat.random(in: -screenWidth / 2 ... screenWidth / 2),
                    height: CGFloat.random(in: -screenHeight / 2 ... screenHeight / 2)
                ),
                color: colors.randomElement()!,
                waveAmplitude: CGFloat.random(in: 20...50),
                waveFrequency: Double.random(in: 3...8), // Random wave frequency
                fallSpeed: Double.random(in: 1.5...3.0),
                startTime: Date().timeIntervalSinceReferenceDate
            )
        }
        serpentines = newSerpentines
    }

    private func animateSerpentine(_ serpentine: Serpentine, screenHeight: CGFloat) {
        let duration = serpentine.fallSpeed
        let startTime = serpentine.startTime

        withAnimation(Animation.linear(duration: duration).repeatCount(1, autoreverses: false)) {
            if let index = serpentines.firstIndex(where: { $0.id == serpentine.id }) {
                // Animate the serpentine falling off the screen
                serpentines[index].offset.height = screenHeight / 2
                Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                    serpentines.removeAll { $0.id == serpentine.id }
                }
            }
        }

        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            let elapsed = Date().timeIntervalSinceReferenceDate - startTime
            if let index = serpentines.firstIndex(where: { $0.id == serpentine.id }) {
                // Use the serpentine's wave frequency for unique horizontal motion
                let newX = serpentine.waveAmplitude * sin(elapsed * serpentine.waveFrequency)
                serpentines[index].offset.width += newX
            } else {
                timer.invalidate()
            }
        }
    }

}

#Preview("Timer Preview") {
    ContentView()
        .frame(width: 400, height: 300) // Specify the size of the preview
}
