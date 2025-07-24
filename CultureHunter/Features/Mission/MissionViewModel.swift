import Foundation
import Combine
import SwiftUI
import UserNotifications

class MissionViewModel: ObservableObject {
    @Published var activeMission: Mission?
    @Published var timeLeftString: String = ""
    
    private var timer: Timer?
    private var missionsKey = "savedMissions"
    private let lastMissionCreationDateKey = "lastMissionCreationDateKey"
    private var isRescheduling = false
    
       private let missionTimeHourKey = "missionTimeHourKey"
       private let missionTimeMinuteKey = "missionTimeMinuteKey"
    
    private var missionHour: Int {
        if UserDefaults.standard.object(forKey: missionTimeHourKey) == nil {
            return 17
        }
        return UserDefaults.standard.integer(forKey: missionTimeHourKey)
    }

    private var missionMinute: Int {
        if UserDefaults.standard.object(forKey: missionTimeMinuteKey) == nil {
            return 45
        }
        return UserDefaults.standard.integer(forKey: missionTimeMinuteKey)
    }
    
    private var avatarViewModel: AvatarViewModel?
    
    private var notificationObserver: NSObjectProtocol?
    
    private let notificationManager = NotificationManager()
        
        private func rescheduleNotifications() {
            notificationManager.cancelMissionNotifications()
            
            scheduleNextDailyMission()
        }
    
    init(avatarViewModel: AvatarViewModel? = nil) {
        self.avatarViewModel = avatarViewModel
        loadSavedMission()
        
        scheduleNextDailyMission()
        
        startTimer()
        
        checkForMissionsAfterAppOpen()
        
                if UserDefaults.standard.object(forKey: missionTimeHourKey) == nil {
                    UserDefaults.standard.set(17, forKey: missionTimeHourKey)
                }
                if UserDefaults.standard.object(forKey: missionTimeMinuteKey) == nil {
                    UserDefaults.standard.set(45, forKey: missionTimeMinuteKey)
                }
                
                setupObservers()
    }
    
    deinit {
            if let observer = notificationObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        
    private func setupObservers() {
        notificationObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            
            guard !self.isRescheduling else { return }
            self.isRescheduling = true
            defer { self.isRescheduling = false }
            
            guard self.missionHour != UserDefaults.standard.integer(forKey: missionTimeHourKey) ||
                  self.missionMinute != UserDefaults.standard.integer(forKey: missionTimeMinuteKey)
            else { return }
            
            self.notificationManager.cancelMissionNotifications()
            
            self.scheduleNextDailyMission()
        }
    }

    func setAvatarViewModel(_ viewModel: AvatarViewModel) {
        self.avatarViewModel = viewModel
    }

    
    func checkForMissionsAfterAppOpen() {
        if shouldCreateNewMission() {
            createNewMission()
        } else if let mission = activeMission, mission.startDate == nil {
            startMission()
        }
    }
    
    private func shouldCreateNewMission() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        
        if let lastCreationDate = UserDefaults.standard.object(forKey: lastMissionCreationDateKey) as? Date,
           calendar.isDate(lastCreationDate, inSameDayAs: now) {
            return false
        }
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = missionHour
        dateComponents.minute = missionMinute
        dateComponents.second = 0
        
        guard let targetTime = calendar.date(from: dateComponents) else {
            return false
        }
        
        return now >= targetTime
    }
    
    
    func startMission() {
        guard var mission = activeMission, mission.startDate == nil else { return }
        mission.startDate = Date()
        self.activeMission = mission
        saveMission()
        updateTimeLeft()
    }
    
    func tryCompleteMission(poiVisited: Bool) -> Int? {
        guard var mission = activeMission,
              !mission.isCompleted,
              let start = mission.startDate,
              poiVisited else { return nil }
        
        let now = Date()
        let timeSinceStart = now.timeIntervalSince(start)
        
        if timeSinceStart > mission.duration {
            timeLeftString = "Tempo scaduto!"
            return nil
        }
        
        mission.isCompleted = true
        self.activeMission = mission
        saveMission()
        return mission.reward
    }
    
    func completeMissionIfActive() -> Int? {
        return tryCompleteMission(poiVisited: true)
    }
    
    func addMissionReward(_ reward: Int) {
        avatarViewModel?.addCoins(reward)
    }
    
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimeLeft()
        }
        
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
        updateTimeLeft()
    }
    
    private func updateTimeLeft() {
        if shouldCreateNewMission() {
            DispatchQueue.main.async {
                print("È ora di creare una nuova missione!")
                self.createNewMission()
            }
            return
        }
        
        guard let mission = activeMission,
              !mission.isCompleted,
              let startDate = mission.startDate else {
            timeLeftString = ""
            return
        }
        
        let now = Date()
        let endTime = startDate.addingTimeInterval(mission.duration)
        
        if now >= endTime {
            timeLeftString = "Tempo scaduto!"
            return
        }
        
        let timeLeft = endTime.timeIntervalSince(now)
        let minutes = Int(timeLeft / 60)
        let seconds = Int(timeLeft.truncatingRemainder(dividingBy: 60))
        
        timeLeftString = "\(minutes) min \(seconds) sec"
    }
    
    private func scheduleNextDailyMission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                self.scheduleNotification()
            }
        }
    }
    
    private func scheduleNotification() {
        let identifier = "daily_mission_notification"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let nextDate = getNextMissionDate()
        
        let content = UNMutableNotificationContent()
        content.title = "Nuova missione disponibile!"
        content.body = "Apri l'app per vedere la tua missione giornaliera e guadagnare monete."
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: nextDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            formatter.timeZone = TimeZone.current
            
            print("Scheduling next mission notification at: \(formatter.string(from: nextDate))")
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                let formattedMinute = String(format: "%02d", self.missionMinute)
                print("Notification scheduled for \(self.missionHour):\(formattedMinute) local time")
            }
        }
    }
    
    private func getNextMissionDate() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        var targetComponents = DateComponents()
        targetComponents.hour = missionHour
        targetComponents.minute = missionMinute
        
        return calendar.nextDate(
            after: now,
            matching: targetComponents,
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? now
    }
    
    private func createNewMission() {
        print("📝 Creazione nuova missione - Orario: \(Date())")
            
        UserDefaults.standard.set(Date(), forKey: lastMissionCreationDateKey)
        
        UserDefaults.standard.removeObject(forKey: missionsKey)
        activeMission = nil
        
        let possibleMissions = [
            (description: "Visita un punto di interesse entro 120 minuti per ottenere 100 monete", reward: 100, duration: 120 * 60.0),
            (description: "Scopri un nuovo POI entro 45 minuti e ottieni 200 monete", reward: 200, duration: 45 * 60.0),(description: "Scopri un nuovo POI entro 15 minuti e ottieni 200 monete", reward: 300, duration: 15 * 60.0),
        ]
        
        let selectedMission = possibleMissions.randomElement()!
        
        activeMission = Mission(
            description: selectedMission.description,
            reward: selectedMission.reward,
            duration: selectedMission.duration
        )
        
        startMission()
        
        DispatchQueue.main.async {
            print("✅ Nuova missione creata: \(self.activeMission?.description ?? "nessuna")")
            self.saveMission()
            self.objectWillChange.send()
        }
    }
    
    private func saveMission() {
        if let data = try? JSONEncoder().encode(activeMission) {
            UserDefaults.standard.set(data, forKey: missionsKey)
        }
    }
    
    private func loadSavedMission() {
        if let data = UserDefaults.standard.data(forKey: missionsKey),
           let mission = try? JSONDecoder().decode(Mission.self, from: data) {
            
            if let startDate = mission.startDate {
                let now = Date()
                let elapsedTime = now.timeIntervalSince(startDate)
                
                if !mission.isCompleted && elapsedTime > mission.duration {
                activeMission = mission
                return
                }
                
                if mission.isCompleted {
                    let calendar = Calendar.current
                        if !calendar.isDate(startDate, inSameDayAs: now) {
                            UserDefaults.standard.removeObject(forKey: missionsKey)
                            activeMission = nil
                            return
                        }
                }
            }
            
            activeMission = mission
        }
    }
    
    #if DEBUG
    func debugForceNewMission() {
        createNewMission()
    }
    #endif
}
