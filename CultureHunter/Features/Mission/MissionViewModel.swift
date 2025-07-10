import Foundation
import Combine
import SwiftUI
import UserNotifications

class MissionViewModel: ObservableObject {
    @Published var activeMission: Mission?
    @Published var timeLeftString: String = ""
    
    private var timer: Timer?
    private var missionsKey = "savedMissions"
    private let missionHour = 10
    private let missionMinute = 44
    
    init() {
        // Carica missione salvata (se presente)
        loadSavedMission()
        
        // Programma la notifica per il giorno successivo
        scheduleNextDailyMission()
        
        // Avvia il timer per aggiornare il contatore
        startTimer()
        
        // Controlla se dobbiamo creare una missione (all'apertura dell'app)
        checkForMissionsAfterAppOpen()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Gestione app aperta/chiusa
    
    // Chiamare quando l'app si apre, per controllare se è necessario creare una missione
    func checkForMissionsAfterAppOpen() {
        // Se non c'è una missione attiva, controlla se ne dobbiamo creare una nuova
        if activeMission == nil {
            // Controlla se l'orario attuale è dopo quello programmato per oggi
            let now = Date()
            let calendar = Calendar.current
            
            // Componiamo la data target di oggi
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
            dateComponents.hour = missionHour
            dateComponents.minute = missionMinute
            dateComponents.second = 0
            
            if let targetTime = calendar.date(from: dateComponents) {
                // Se l'orario attuale è dopo quello programmato, crea una missione
                if now >= targetTime {
                    createNewMission()
                }
            }
        }
        
        // Se c'è una missione attiva ma non ancora avviata, la avvia
        if var mission = activeMission, mission.startDate == nil {
            startMission()
        }
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
        //DA IMPLEMENTARE COMPLETAMENTO MISSIONE
        if now.timeIntervalSince(start) <= mission.duration {
            mission.isCompleted = true
            self.activeMission = mission
            saveMission()
            return mission.reward
        }
        return nil
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
            if var expiredMission = activeMission, !expiredMission.isCompleted {
                expiredMission.isCompleted = true
                activeMission = expiredMission
                saveMission()
            }
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
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Errore nella programmazione della notifica: \(error.localizedDescription)")
            } else {
                print("Notifica programmata per le \(self.missionHour):\(self.missionMinute)")
            }
        }
    }
    
    // Calcola la data della prossima missione
    private func getNextMissionDate() -> Date {
        let now = Date()
        let calendar = Calendar.current
        
        // Crea i componenti per oggi all'ora specificata
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = missionHour
        dateComponents.minute = missionMinute
        dateComponents.second = 0
        
        guard let todayTarget = calendar.date(from: dateComponents) else {
            return now
        }
        
        // Se l'orario di oggi è già passato, programma per domani
        if now >= todayTarget {
            return calendar.date(byAdding: .day, value: 1, to: todayTarget) ?? now
        }
        
        return todayTarget
    }
    
    // MARK: - Creazione missione
    
    private func createNewMission() {
        // Definisci possibili missioni
        let possibleMissions = [
            (description: "Visita un punto di interesse entro 120 minuti per ottenere 100 monete", reward: 100, duration: 120 * 60.0),
            (description: "Scopri un nuovo POI entro 60 minuti e ottieni 200 monete", reward: 150, duration: 45 * 60.0)
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
            
            // Rimuovi missioni vecchie completate
            if mission.isCompleted {
                if let startDate = mission.startDate, Date().timeIntervalSince(startDate) > 24*60*60 {
                    UserDefaults.standard.removeObject(forKey: missionsKey)
                    return
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
