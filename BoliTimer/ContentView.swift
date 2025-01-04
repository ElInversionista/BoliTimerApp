import SwiftUI

struct Serpentine: Identifiable {
    let id = UUID()
    var offset: CGSize
    var color: Color
    var waveAmplitude: CGFloat
    var waveFrequency: Double
    var speed: Double
    var angle: Double
    var startTime: Double
}

struct ContentView: View {
    @State private var timerValue: Int = 0
    @State private var timer: Timer? = nil
    @State private var buttonClicked: Bool = false
    @State private var longEffect: Bool = false
    @State private var serpentines: [Serpentine] = []
    @State private var textScaled: Bool = false
    @State private var centralizedTimer: Timer? = nil

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    // Timer Text
                    Text(formatTime(from: timerValue))
                        .font(.system(size: 120, weight: .bold, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .scaleEffect(textScaled ? 3 : 1.0) // Apply scale effect
                        .animation(.easeInOut(duration: 0.3), value: textScaled)

                    // Start Button
                    Button(action: {
                        // Scale the text temporarily
                        textScaled = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            textScaled = false
                        }

                        // Trigger serpentines and start the timer
                        triggerSerpentineExplosion(
                            screenWidth: geometry.size.width,
                            screenHeight: geometry.size.height
                        )
                        // Schedule ten more explosions at 0.1-second intervals
                        for i in 1...5 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                triggerSerpentineExplosion(
                                    screenWidth: geometry.size.width,
                                    screenHeight: geometry.size.height
                                )
                            }
                        }
                        startOrResetTimer()
                    }) {
                        Text("Start")
                            .font(.system(size: 24, weight: .bold))
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }

                // Serpentines Layer
                ForEach(serpentines) { serpentine in
                    Rectangle()
                        .fill(serpentine.color)
                        .frame(
                            width: 10 + serpentine.waveAmplitude,
                            height: 40 + serpentine.waveAmplitude
                        )
                        .offset(serpentine.offset)
                }
            }
        }
    }

    private func startOrResetTimer() {
        timer?.invalidate() // Stop any existing timer
        timerValue = 0 // Reset the timer value to 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timerValue += 1 // Increment the timer value every second
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
        let newSerpentines = (1...60).map { _ in
            Serpentine(
                offset: CGSize(
                    width: CGFloat.random(in: -screenWidth / 2 ... screenWidth / 2),
                    height: CGFloat.random(in: -screenHeight / 2 ... screenHeight / 2)
                ),
                color: colors.randomElement()!,
                waveAmplitude: 1.0,
                waveFrequency: Double.random(in: 3...8),
                speed: Double.random(in: 1.5...3.0),
                angle: Double.random(in: 0...360),
                startTime: Date().timeIntervalSinceReferenceDate
            )
        }
        serpentines.append(contentsOf: newSerpentines)
        startCentralizedAnimation(screenWidth: screenWidth, screenHeight: screenHeight)
    }

    private func startCentralizedAnimation(screenWidth: CGFloat, screenHeight: CGFloat) {
        centralizedTimer?.invalidate()

        centralizedTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            let currentTime = Date().timeIntervalSinceReferenceDate

            for index in (0..<serpentines.count).reversed() {
                var serpentine = serpentines[index]
                let elapsed = currentTime - serpentine.startTime

                let angleInRadians = serpentine.angle * (.pi / 180)
                let dx = cos(angleInRadians) * serpentine.speed
                let dy = sin(angleInRadians) * serpentine.speed

                serpentine.offset.width += dx
                serpentine.offset.height += dy

                if elapsed >= 4.0 && elapsed < 4.5 {
                    // Trigger the burst by scaling the serpentine rapidly
                    let burstScale = 1.0 + (elapsed - 4.0) * 80.0  // Fast increase for burst effect
                    serpentine.waveAmplitude = burstScale
                } else if elapsed >= 4.5 {
                    // Remove the serpentine after the burst
                    serpentines.remove(at: index)
                    continue
                } else {
                    serpentine.waveAmplitude = 1.0
                }

                // Check for out-of-bounds serpentines
                if abs(serpentine.offset.width) > screenWidth / 2 ||
                    abs(serpentine.offset.height) > screenHeight / 2 {
                    serpentines.remove(at: index)
                } else {
                    serpentines[index] = serpentine
                }
            }

            if serpentines.isEmpty {
                timer.invalidate()
                centralizedTimer = nil
            }
        }
    }

}


#Preview("Timer Preview") {
    ContentView()
        .frame(width: 800, height: 600) // Specify the size of the preview
}
    
