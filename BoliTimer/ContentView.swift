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
    @State private var timerValues: [Int] = Array(repeating: 0, count: 20)
    @State private var timerObjects: [Timer?] = Array(repeating: nil, count: 20)
    @State private var timerTitles: [String] = Array(repeating: "Timer", count: 20)
    @State private var serpentines: [[Serpentine]] = Array(repeating: [], count: 20)
    @State private var timerCount: String = "20" // Default number of timers
    @State private var timerScales: [CGFloat] = Array(repeating: 1.0, count: 20)

    var body: some View {
        GeometryReader { geometry in
            let totalPadding: CGFloat = 40
            let baseContainerWidth = (geometry.size.width - totalPadding * 2 - 60) / 4
            let baseContainerHeight = (baseContainerWidth * 1.2) * 0.4
            
            ScrollView {
                VStack(spacing: 20) {
                    // Timer Count TextField
                    TextField("Enter number (e.g., 3, 6, 9)", text: $timerCount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 200)
                        .padding()

                    // Button to add timers based on input
                    Button(action: {
                        // Validate the input
                        if let count = Int(timerCount), count > 0 {
                            updateTimerContainers(count: count)
                        } else {
                            print("Invalid input for timer count.")
                        }
                    }) {
                        Text("Add Timers")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    
                    // Timer Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 20) {
                        ForEach(0..<timerValues.count, id: \.self) { index in
                            VStack(spacing: 12) {
                                // Title
                                TextField("Enter Title", text: $timerTitles[index])
                                    .font(.system(size: 35, weight: .medium))
                                    .foregroundColor(.black)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                
                                // Timer Counter
                                Text(formatTime(from: timerValues[index]))
                                    .font(.system(size: 35, weight: .bold, design: .monospaced))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .scaleEffect(timerScales[index]) // Apply the scaling effect
                                
                                // Button
                                Button(action: {
                                    startTimer(index: index, screenWidth: geometry.size.width, screenHeight: geometry.size.height)
                                }) {
                                    Text("Start")
                                        .font(.system(size: 35, weight: .bold))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .frame(
                                width: baseContainerWidth,
                                height: baseContainerHeight
                            )
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                            .overlay(
                                ZStack {
                                    ForEach(serpentines[index]) { serpentine in
                                        Rectangle()
                                            .fill(serpentine.color)
                                            .frame(width: 10 + serpentine.waveAmplitude, height: 40 + serpentine.waveAmplitude)
                                            .offset(serpentine.offset)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(totalPadding)
            }
        }
    }
    
    private func updateTimerContainers(count: Int) {
        let currentCount = timerValues.count
        
        if count > currentCount {
            // Add additional elements
            let additionalCount = count - currentCount
            timerValues.append(contentsOf: Array(repeating: 0, count: additionalCount))
            timerObjects.append(contentsOf: Array(repeating: nil, count: additionalCount))
            timerTitles.append(contentsOf: Array(repeating: "Timer", count: additionalCount))
            serpentines.append(contentsOf: Array(repeating: [], count: additionalCount))
            timerScales.append(contentsOf: Array(repeating: 1.0, count: additionalCount))
        } else if count < currentCount {
            // Remove excess elements
            timerValues.removeLast(currentCount - count)
            timerObjects.removeLast(currentCount - count)
            timerTitles.removeLast(currentCount - count)
            serpentines.removeLast(currentCount - count)
            timerScales.removeLast(currentCount - count)
        }
    }

    
    private func startTimer(index: Int, screenWidth: CGFloat, screenHeight: CGFloat) {
        // Reset timer and initialize counter
        timerObjects[index]?.invalidate()
        timerValues[index] = 0
        timerObjects[index] = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            timerValues[index] += 1
        }
        
        // Trigger scaling animation
        withAnimation(.easeInOut(duration: 0.2)) {
            timerScales[index] = 3.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.2)) {
                timerScales[index] = 1.0
            }
        }
        
        // Trigger Serpentine Explosion 4 times with a delay of 0.1 seconds
        for i in 0..<10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                triggerSerpentineExplosion(index: index, screenWidth: screenWidth, screenHeight: screenHeight)
            }
        }
    }

    
    private func formatTime(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
    private func triggerSerpentineExplosion(index: Int, screenWidth: CGFloat, screenHeight: CGFloat) {
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
        serpentines[index] = newSerpentines
        startCentralizedAnimation(index: index, screenWidth: screenWidth, screenHeight: screenHeight)
    }
    
    private func startCentralizedAnimation(index: Int, screenWidth: CGFloat, screenHeight: CGFloat) {
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            let currentTime = Date().timeIntervalSinceReferenceDate

            for i in (0..<serpentines[index].count).reversed() {
                var serpentine = serpentines[index][i]
                let elapsed = currentTime - serpentine.startTime

                let angleInRadians = serpentine.angle * (.pi / 180)
                let dx = cos(angleInRadians) * serpentine.speed
                let dy = sin(angleInRadians) * serpentine.speed

                serpentine.offset.width += dx
                serpentine.offset.height += dy

                if elapsed >= 4.0 {
                    let scale = 1.0 + 0.5 * sin((elapsed - 4.0) * 4.0)
                    serpentine.waveAmplitude = scale
                } else {
                    serpentine.waveAmplitude = 1.0
                }

                if abs(serpentine.offset.width) > screenWidth / 2 || abs(serpentine.offset.height) > screenHeight / 2 {
                    serpentines[index].remove(at: i)
                } else {
                    serpentines[index][i] = serpentine
                }
            }

            if serpentines[index].isEmpty {
                timer.invalidate()
            }
        }
    }
}

#Preview("Timer Preview") {
    ContentView()
        .frame(width: 1400, height: 1300)
}

