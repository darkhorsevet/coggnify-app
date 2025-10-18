//
//  ReminderManager.swift
//  Notalyze
//
//  Manages follow-up reminders and notifications
//

import Foundation
import UserNotifications
import EventKit

class ReminderManager: ObservableObject {
    @Published var upcomingReminders: [FollowUpReminder] = []
    @Published var overdueReminders: [FollowUpReminder] = []
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let eventStore = EKEventStore()
    private let storage = ReminderStorage.shared
    
    init() {
        loadReminders()
        requestNotificationPermission()
    }
    
    // MARK: - Permissions
    
    func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else {
                print("❌ Notification permission denied")
            }
        }
    }
    
    func requestCalendarPermission() {
        eventStore.requestAccess(to: .reminder) { granted, error in
            if granted {
                print("✅ Calendar permission granted")
            }
        }
    }
    
    // MARK: - Create Reminders
    
    func createReminder(
        patientName: String,
        clientName: String,
        task: String,
        dueDate: Date,
        notes: String = "",
        consultation: Consultation? = nil
    ) -> FollowUpReminder {
        
        let reminder = FollowUpReminder(
            id: UUID(),
            patientName: patientName,
            clientName: clientName,
            task: task,
            dueDate: dueDate,
            notes: notes,
            consultationId: consultation?.id,
            isCompleted: false,
            createdDate: Date()
        )
        
        storage.save(reminder)
        scheduleNotification(for: reminder)
        loadReminders()
        
        return reminder
    }
    
    func createRemindersFromActionItems(
        _ actionItems: [ActionItem],
        patientName: String,
        clientName: String,
        consultation: Consultation? = nil
    ) {
        for item in actionItems {
            guard item.responsibleParty.lowercased().contains("vet") else { continue }
            
            let dueDate = parseDueDate(from: item.deadline)
            createReminder(
                patientName: patientName,
                clientName: clientName,
                task: item.task,
                dueDate: dueDate,
                notes: "From consultation action items",
                consultation: consultation
            )
        }
    }
    
    func createSmartReminder(from consultation: Consultation) {
        // Automatically suggest follow-ups based on consultation type
        let (task, days) = suggestedFollowUp(for: consultation.type)
        
        if let daysAhead = days {
            let dueDate = Calendar.current.date(byAdding: .day, value: daysAhead, to: Date()) ?? Date()
            createReminder(
                patientName: consultation.patientName,
                clientName: consultation.ownerName,
                task: task,
                dueDate: dueDate,
                notes: "Suggested follow-up for \(consultation.type.rawValue)",
                consultation: consultation
            )
        }
    }
    
    private func suggestedFollowUp(for type: ConsultationType) -> (String, Int?) {
        switch type {
        case .colicEvaluation:
            return ("Follow-up call to check on colic resolution", 1)
        case .lamenessExam:
            return ("Recheck lameness and treatment response", 3)
        case .woundCare:
            return ("Check wound healing and change bandage", 2)
        case .dentalExam:
            return ("Next dental examination", 180)
        case .colicevaluation:
            return ("Post-colic follow-up", 1)
        case .reproductiveCheck:
            return ("Breeding soundness recheck", 21)
        default:
            return ("Follow-up consultation", 7)
        }
    }
    
    private func parseDueDate(from deadline: String) -> Date {
        let lowercased = deadline.lowercased()
        let calendar = Calendar.current
        
        // Parse common date formats
        if lowercased.contains("today") {
            return Date()
        } else if lowercased.contains("tomorrow") {
            return calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        } else if lowercased.contains("3 days") || lowercased.contains("three days") {
            return calendar.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        } else if lowercased.contains("week") || lowercased.contains("7 days") {
            return calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        } else if lowercased.contains("2 weeks") {
            return calendar.date(byAdding: .day, value: 14, to: Date()) ?? Date()
        } else {
            // Default to 3 days if can't parse
            return calendar.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        }
    }
    
    // MARK: - Notifications
    
    private func scheduleNotification(for reminder: FollowUpReminder) {
        let content = UNMutableNotificationContent()
        content.title = "Follow-up Reminder"
        content.body = "\(reminder.patientName) - \(reminder.task)"
        content.sound = .default
        content.badge = 1
        content.userInfo = ["reminderId": reminder.id.uuidString]
        
        // Add action buttons
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE",
            title: "Mark Complete",
            options: .foreground
        )
        let callAction = UNNotificationAction(
            identifier: "CALL_CLIENT",
            title: "Call \(reminder.clientName)",
            options: .foreground
        )
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Remind Tomorrow",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "FOLLOWUP_REMINDER",
            actions: [completeAction, callAction, snoozeAction],
            intentIdentifiers: []
        )
        notificationCenter.setNotificationCategories([category])
        content.categoryIdentifier = "FOLLOWUP_REMINDER"
        
        // Schedule for due date
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            } else {
                print("✅ Scheduled reminder for \(reminder.patientName)")
            }
        }
    }
    
    // MARK: - Manage Reminders
    
    func completeReminder(_ reminder: FollowUpReminder) {
        var updated = reminder
        updated.isCompleted = true
        updated.completedDate = Date()
        storage.update(updated)
        
        // Remove notification
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
        
        loadReminders()
    }
    
    func snoozeReminder(_ reminder: FollowUpReminder, by days: Int = 1) {
        var updated = reminder
        updated.dueDate = Calendar.current.date(byAdding: .day, value: days, to: updated.dueDate) ?? updated.dueDate
        storage.update(updated)
        
        // Reschedule notification
        scheduleNotification(for: updated)
        
        loadReminders()
    }
    
    func deleteReminder(_ reminder: FollowUpReminder) {
        storage.delete(reminder)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
        loadReminders()
    }
    
    func loadReminders() {
        let allReminders = storage.loadAll()
        
        let now = Date()
        upcomingReminders = allReminders
            .filter { !$0.isCompleted && $0.dueDate >= now }
            .sorted { $0.dueDate < $1.dueDate }
        
        overdueReminders = allReminders
            .filter { !$0.isCompleted && $0.dueDate < now }
            .sorted { $0.dueDate > $1.dueDate }
    }
    
    // MARK: - Calendar Integration
    
    func addToCalendar(_ reminder: FollowUpReminder) {
        let event = EKReminder(eventStore: eventStore)
        event.title = "\(reminder.patientName) - \(reminder.task)"
        event.notes = reminder.notes
        event.calendar = eventStore.defaultCalendarForNewReminders()
        
        let alarm = EKAlarm(absoluteDate: reminder.dueDate)
        event.addAlarm(alarm)
        
        do {
            try eventStore.save(event, commit: true)
            print("✅ Added to calendar")
        } catch {
            print("❌ Failed to add to calendar: \(error)")
        }
    }
}

// MARK: - Reminder Model

struct FollowUpReminder: Identifiable, Codable, Hashable {
    let id: UUID
    var patientName: String
    var clientName: String
    var task: String
    var dueDate: Date
    var notes: String
    var consultationId: UUID?
    var isCompleted: Bool
    var completedDate: Date?
    let createdDate: Date
    
    var isOverdue: Bool {
        return !isCompleted && dueDate < Date()
    }
    
    var daysUntilDue: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        return days
    }
    
    var dueDateFormatted: String {
        if Calendar.current.isDateInToday(dueDate) {
            return "Today at " + dueDate.formatted(date: .omitted, time: .shortened)
        } else if Calendar.current.isDateInTomorrow(dueDate) {
            return "Tomorrow at " + dueDate.formatted(date: .omitted, time: .shortened)
        } else {
            return dueDate.formatted(date: .abbreviated, time: .shortened)
        }
    }
}

// MARK: - Storage

class ReminderStorage {
    static let shared = ReminderStorage()
    
    private let remindersKey = "SavedReminders"
    private let defaults = UserDefaults.standard
    
    func save(_ reminder: FollowUpReminder) {
        var reminders = loadAll()
        reminders.append(reminder)
        saveAll(reminders)
    }
    
    func update(_ reminder: FollowUpReminder) {
        var reminders = loadAll()
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            saveAll(reminders)
        }
    }
    
    func delete(_ reminder: FollowUpReminder) {
        var reminders = loadAll()
        reminders.removeAll { $0.id == reminder.id }
        saveAll(reminders)
    }
    
    func loadAll() -> [FollowUpReminder] {
        guard let data = defaults.data(forKey: remindersKey),
              let reminders = try? JSONDecoder().decode([FollowUpReminder].self, from: data) else {
            return []
        }
        return reminders
    }
    
    private func saveAll(_ reminders: [FollowUpReminder]) {
        if let data = try? JSONEncoder().encode(reminders) {
            defaults.set(data, forKey: remindersKey)
        }
    }
}
