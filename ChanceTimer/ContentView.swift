import SwiftUI
import UserNotifications

func formatElapsedTime(_ seconds: Int) -> String {
    let minutesPart = seconds / 60
    let secondsPart = seconds % 60
    return String(format: "%02d:%02d", minutesPart, secondsPart)
}

struct ContentView: View {
    @State private var isScreenBlack = false
    @State private var startTime = 50.0
    @State private var endTime = 70.0
    @State private var isTimerActive = false
    @State private var timer: Timer?
    @State private var elapsedTime = 0
    
    var body: some View {
        ZStack {
            if !isScreenBlack {
                Color.clear
                    .contentShape(Rectangle()) // Makes the entire area tappable
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if (isTimerActive) {
                            isScreenBlack = true
                        }
                    }
            }

            if isScreenBlack {
                Color.black.edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isScreenBlack = false
                    }
            }
            VStack {
                (Text("Sit at least ") + Text("\(Int(startTime))").bold() + Text(" minutes"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title2)
                
                HStack {
                    Text("1")
                    if (!isScreenBlack) {
                        Slider(value: $startTime, in: 1...180)
                            .disabled(isTimerActive)
                            .onChange(of: startTime) {
                                startTime = Double(Int(startTime.rounded()))
                                if startTime >= endTime {
                                    startTime = max(endTime - 1, 1)
                                }
                            }
                        Text("180")
                    }
                }
                
                (Text("And up to ") + Text("\(Int(endTime))").bold() + Text(" minutes"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title2)
                
                HStack {
                    Text("1")
                    if (!isScreenBlack) {
                        Slider(value: $endTime, in: 1...180)
                            .disabled(isTimerActive)
                            .onChange(of: endTime) {
                                endTime = Double(Int(endTime.rounded()))
                                if endTime <= startTime {
                                    endTime = min(startTime + 1, 180)
                                }
                            }
                    }
                    Text("180")
                }
                
                if (!isScreenBlack) {
                    Button(action: {
                        self.startRandomTimer()
                    }) {
                        Text(isTimerActive ? "Stop" : "Start")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(isTimerActive ? Color.red : Color.green)
                            .cornerRadius(40)
                    }
                }
                if isTimerActive {
                    Text(formatElapsedTime(elapsedTime))
                        .font(.title2)
                } else {
                    Text(" ")
                        .font(.title2)
                        .opacity(0)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func startRandomTimer() {
        let randomTimeInterval = Double.random(in: (startTime * 60)...(endTime * 60))
        print(String(startTime) + ", " + String(randomTimeInterval) + ", " + String(endTime))
        isTimerActive.toggle()
        
        let notificationCenter = UNUserNotificationCenter.current()
        if isTimerActive {
            elapsedTime = 0
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                elapsedTime += 1
                if (elapsedTime >= Int(randomTimeInterval)) {
                    isTimerActive = false;
                    timer?.invalidate()
                    timer = nil
                }
            }
            notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
                if granted {
                    let content = UNMutableNotificationContent()
                    content.title = "Time's Up!"
                    content.body = "Your timer has finished."
                    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "bell.wav"))
                    //content.sound = UNNotificationSound.default
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: randomTimeInterval, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    notificationCenter.add(request) { error in
                        if let error = error {
                            print("Error scheduling notification: \(error)")
                        }
                    }
                    print("added timer for " + String(Int(randomTimeInterval)) + " seconds")
                } else {
                    print("Didn't get permission. \(error)")
                    isTimerActive = false
                }
            }
        } else {
            timer?.invalidate()
            timer = nil
            notificationCenter.removeAllPendingNotificationRequests()
            print("removed timer")
        }
    }
}
