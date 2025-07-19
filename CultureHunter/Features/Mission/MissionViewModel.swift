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
    
    // New keys for mission time
       private let missionTimeHourKey = "missionTimeHourKey"
       private let missionTimeMinuteKey = "missionTimeMinuteKey"
    
    // Computed properties for mission time
    private var missionHour: Int {
        // Check if the key exists at all
        if UserDefaults.standard.object(forKey: missionTimeHourKey) == nil {
            return 17 // Default to 17:00
        }
        return UserDefaults.standard.integer(forKey: missionTimeHourKey)
    }

    private var missionMinute: Int {
        // Check if the key exists at all
        if UserDefaults.standard.object(forKey: missionTimeMinuteKey) == nil {
            return 45 // Default to 45 minutes
        }
        return UserDefaults.standard.integer(forKey: missionTimeMinuteKey)
    }
    
    private var avatarViewModel: AvatarViewModel?
    
    private var notificationObserver: NSObjectProtocol?
    
    private let notificationManager = NotificationManager()
        
        private func rescheduleNotifications() {
            // Cancel existing notifications first
            notificationManager.cancelMissionNotifications()
            
            // Then schedule new ones
            scheduleNextDailyMission()
        }
    
    init(avatarViewModel: AvatarViewModel? = nil) {
        self.avatarViewModel = avatarViewModel
        // Carica missione salvata (se presente)
        loadSavedMission()
        
        // Programma la notifica per il giorno successivo
        scheduleNextDailyMission()
        
        // Avvia il timer per aggiornare il contatore
        startTimer()
        
        // Controlla se dobbiamo creare una missione (all'apertura dell'app)
        checkForMissionsAfterAppOpen()
        
        // Set default mission time if needed
                if UserDefaults.standard.object(forKey: missionTimeHourKey) == nil {
                    UserDefaults.standard.set(17, forKey: missionTimeHourKey)
                }
                if UserDefaults.standard.object(forKey: missionTimeMinuteKey) == nil {
                    UserDefaults.standard.set(45, forKey: missionTimeMinuteKey)
                }
                
                // Observe UserDefaults changes
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
            
            // Add reentrancy guard here
            guard !self.isRescheduling else { return }
            self.isRescheduling = true
            defer { self.isRescheduling = false }
            
            // Add check to prevent unnecessary calls
            guard self.missionHour != UserDefaults.standard.integer(forKey: missionTimeHourKey) ||
                  self.missionMinute != UserDefaults.standard.integer(forKey: missionTimeMinuteKey)
            else { return }
            
            self.notificationManager.cancelMissionNotifications()
            
            // DON'T reset last mission creation date here
            // UserDefaults.standard.removeObject(forKey: self.lastMissionCreationDateKey)
            
            self.scheduleNextDailyMission()
        }
    }
    
    // Metodo per impostare l'avatarViewModel dopo l'inizializzazione
    func setAvatarViewModel(_ viewModel: AvatarViewModel) {
        self.avatarViewModel = viewModel
    }

    
    // MARK: - Gestione app aperta/chiusa
    
    // Chiamare quando l'app si apre, per controllare se è necessario creare una missione
    func checkForMissionsAfterAppOpen() {
        // Controlla se è il momento di creare una nuova missione
        if shouldCreateNewMission() {
            createNewMission()
        } else if let mission = activeMission, mission.startDate == nil {
            // Se c'è una missione attiva ma non ancora avviata, la avvia
            startMission()
        }
    }
    
    // Nuova funzione per determinare se dobbiamo creare una nuova missione
    private func shouldCreateNewMission() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        
        // Check if we already have a mission for today
        if let lastCreationDate = UserDefaults.standard.object(forKey: lastMissionCreationDateKey) as? Date,
           calendar.isDate(lastCreationDate, inSameDayAs: now) {
            return false
        }
        
        // Calculate today's mission time with new time
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = missionHour
        dateComponents.minute = missionMinute
        dateComponents.second = 0
        
        guard let targetTime = calendar.date(from: dateComponents) else {
            return false
        }
        
        // Only create mission if we're past the target time
        return now >= targetTime
    }
    
    // MARK: - Gestione missione
    
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
        
        // Controlla se il tempo è scaduto
        if timeSinceStart > mission.duration {
            timeLeftString = "Tempo scaduto!"
            return nil
        }
        
        // Completa la missione solo se entro il tempo limite
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
    
    // MARK: - Timer e aggiornamenti UI
    
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
        // 1. Prima controlla se è ora di creare una nuova missione
        if shouldCreateNewMission() {
            DispatchQueue.main.async {
                print("È ora di creare una nuova missione!")
                self.createNewMission()
            }
            return
        }
        
        // 2. Se non è ora di una nuova missione, aggiorna il timer esistente
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
    
    // MARK: - Scheduling Notifiche
    
    // Programma la prossima notifica giornaliera
    private func scheduleNextDailyMission() {
        // Richiedi i permessi per le notifiche
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                self.scheduleNotification()
            }
        }
    }
    
    private func scheduleNotification() {
        // Rimuovi notifiche precedenti
        let identifier = "daily_mission_notification"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // Calcola la prossima data per la missione
        let nextDate = getNextMissionDate()
        
        // Crea il contenuto della notifica
        let content = UNMutableNotificationContent()
        content.title = "Nuova missione disponibile!"
        content.body = "Apri l'app per vedere la tua missione giornaliera e guadagnare monete."
        content.sound = .default
        
        // Crea un trigger per l'orario specifico
        let components = Calendar.current.dateComponents([.hour, .minute], from: nextDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Crea e aggiungi la richiesta
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
                // Format with leading zeros for minutes
                let formattedMinute = String(format: "%02d", self.missionMinute)
                print("Notification scheduled for \(self.missionHour):\(formattedMinute) local time")
            }
        }
    }
    
    // In getNextMissionDate() - fix date wrapping at midnight
    private func getNextMissionDate() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Create components for today's mission time
        var targetComponents = DateComponents()
        targetComponents.hour = missionHour
        targetComponents.minute = missionMinute
        
        // Find next matching time in local timezone
        return calendar.nextDate(
            after: now,
            matching: targetComponents,
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? now
    }
    
    // MARK: - Creazione missione
    
    private func createNewMission() {
        print("📝 Creazione nuova missione - Orario: \(Date())")
            
        // Salva la data di creazione
        UserDefaults.standard.set(Date(), forKey: lastMissionCreationDateKey)
        
        // Rimuovi missione precedente
        UserDefaults.standard.removeObject(forKey: missionsKey)
        activeMission = nil
        
        // Definisci possibili missioni
        let possibleMissions = [
            (description: "Visita un punto di interesse entro 120 minuti per ottenere 100 monete", reward: 100, duration: 120 * 60.0),
            (description: "Scopri un nuovo POI entro 45 minuti e ottieni 200 monete", reward: 200, duration: 45 * 60.0),(description: "Scopri un nuovo POI entro 15 minuti e ottieni 200 monete", reward: 300, duration: 15 * 60.0),
        ]
        
        // Scegli casualmente
        let selectedMission = possibleMissions.randomElement()!
        
        // Crea la nuova missione
        activeMission = Mission(
            description: selectedMission.description,
            reward: selectedMission.reward,
            duration: selectedMission.duration
        )
        
        // Avvia automaticamente
        startMission()
        
        // Forza l'aggiornamento su main thread
        DispatchQueue.main.async {
            print("✅ Nuova missione creata: \(self.activeMission?.description ?? "nessuna")")
            self.saveMission()
            self.objectWillChange.send() // Forza aggiornamento UI
        }
        if let mission = activeMission {
                    notificationManager.sendMissionNotification(
                        description: mission.description,
                        reward: mission.reward
                    )
                }
    }
    
    // MARK: - Persistenza
    
    private func saveMission() {
        if let data = try? JSONEncoder().encode(activeMission) {
            UserDefaults.standard.set(data, forKey: missionsKey)
        }
    }
    
    private func loadSavedMission() {
        if let data = UserDefaults.standard.data(forKey: missionsKey),
           let mission = try? JSONDecoder().decode(Mission.self, from: data) {
            
            // Controlla se la missione è scaduta
            if let startDate = mission.startDate {
                let now = Date()
                let elapsedTime = now.timeIntervalSince(startDate)
                
                // Se la missione non è completata ed è scaduta
                if !mission.isCompleted && elapsedTime > mission.duration {
                    // Non rimuovere, segnala come scaduta
                    activeMission = mission
                    return
                }
                
                // Se la missione completata non è di oggi, rimuovila
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
    
    // Per il debug
    #if DEBUG
    func debugForceNewMission() {
        createNewMission()
    }
    #endif
}
