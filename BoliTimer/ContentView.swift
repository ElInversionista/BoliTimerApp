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
    @State private var timerValues: [Int] = []
    @State private var timerObjects: [Timer?] = []
    @State private var timerTitles: [String] = []
    @State private var serpentines: [[Serpentine]] = []
    @State private var timerCount: String = "" // Text input for dynamic timer count
    @State private var timerContainers: Int = 20 // Start with 20 timers by default
    
    var body: some View {
        GeometryReader { geometry in
            let totalPadding: CGFloat = 40
            let containerWidth = (geometry.size.width - totalPadding * 2 - 60) / 4
            let containerHeight = containerWidth * 0.8
            
            VStack(spacing: 20) {
                // Timer Count TextField
                TextField("Enter number (e.g., 3, 6, 9)", text: $timerCount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
                    .padding()
                
                // Button to add timers based on input
                Button(action: {
                    if let count = Int(timerCount), count > 0 {
                        // Update the number of timers
                        timerContainers = count
                        updateStateArrays(for: count)
                    }
                }) {
                    Text("Add Timers")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // Timer Grid
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4),
                        spacing: 20
                    ) {
                        ForEach(0..<timerContainers, id: \.self) { index in
                            VStack(spacing: 12) {
                                // Title
                                TextField("Enter Title", text: Binding(
                                    get: { timerTitles.indices.contains(index) ? timerTitles[index] : "" },
                                    set: { newValue in
                                        if timerTitles.indices.contains(index) {
                                            timerTitles[index] = newValue
                                        }
                                    }
                                ))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                
                                // Timer Counter
                                Text(formatTime(from: timerValues.indices.contains(index) ? timerValues[index] : 0))
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                
                                // Button
                                Button(action: {
                                    startTimer(index: index, screenWidth: geometry.size.width, screenHeight: geometry.size.height)
                                }) {
                                    Text("Start")
                                        .font(.system(size: 16, weight: .bold))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .frame(
                                width: containerWidth,
                                height: containerHeight
                            )
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                            .overlay(
                                ZStack {
                                    ForEach(serpentines.indices.contains(index) ? serpentines[index] : []) { serpentine in
                                        Rectangle()
                                            .fill(serpentine.color)
                                            .frame(width: 10 + serpentine.waveAmplitude, height: 40 + serpentine.waveAmplitude)
                                            .offset(serpentine.offset)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, totalPadding)
                }
            }
        }
        .onAppear {
            // Initialize state arrays for 20 timers
            updateStateArrays(for: timerContainers)
        }
    }
    
    private func updateStateArrays(for count: Int) {
        let additionalCount = count - timerTitles.count
        
        if additionalCount > 0 {
            timerTitles.append(contentsOf: Array(repeating: "Timer", count: additionalCount))
            timerValues.append(contentsOf: Array(repeating: 0, count: additionalCount))
            timerObjects.append(contentsOf: Array(repeating: nil, count: additionalCount))
            serpentines.append(contentsOf: Array(repeating: [], count: additionalCount))
        }
    }
    
    private func startTimer(index: Int, screenWidth: CGFloat, screenHeight: CGFloat) {
        guard timerValues.indices.contains(index) else { return }
        
        timerObjects[index]?.invalidate()
        timerValues[index] = 0
        timerObjects[index] = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timerValues.indices.contains(index) {
                timerValues[index] += 1
            }
        }
        triggerSerpentineExplosion(index: index, screenWidth: screenWidth, screenHeight: screenHeight)
    }
    
    private func formatTime(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
    private func triggerSerpentineExplosion(index: Int, screenWidth: CGFloat, screenHeight: CGFloat) {
        guard serpentines.indices.contains(index) else { return }
        
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
    }
}

#Preview("Timer Preview") {
    ContentView()
        .frame(width: 1400, height: 1300)
}

