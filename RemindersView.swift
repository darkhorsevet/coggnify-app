//
//  RemindersView.swift
//  Notalyze
//
//  View for managing follow-up reminders
//

import SwiftUI

struct RemindersView: View {
    @StateObject private var reminderManager = ReminderManager()
    @State private var showingNewReminder = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if reminderManager.upcomingReminders.isEmpty && reminderManager.overdueReminders.isEmpty {
                    EmptyRemindersView(showingNewReminder: $showingNewReminder)
                } else {
                    List {
                        // Overdue Section
                        if !reminderManager.overdueReminders.isEmpty {
                            Section {
                                ForEach(reminderManager.overdueReminders) { reminder in
                                    ReminderRow(reminder: reminder, reminderManager: reminderManager)
                                }
                            } header: {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text("Overdue (\(reminderManager.overdueReminders.count))")
                                }
                            }
                        }
                        
                        // Upcoming Section
                        if !reminderManager.upcomingReminders.isEmpty {
                            Section("Upcoming") {
                                ForEach(reminderManager.upcomingReminders) { reminder in
                                    ReminderRow(reminder: reminder, reminderManager: reminderManager)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Follow-ups")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewReminder = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
            }
            .sheet(isPresented: $showingNewReminder) {
                NewReminderSheet(reminderManager: reminderManager)
            }
            .onAppear {
                reminderManager.loadReminders()
            }
        }
    }
}

// MARK: - Reminder Row

struct ReminderRow: View {
    let reminder: FollowUpReminder
    @ObservedObject var reminderManager: ReminderManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Complete checkbox
            Button(action: {
                reminderManager.completeReminder(reminder)
            }) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(reminder.isCompleted ? .green : (reminder.isOverdue ? .red : .secondary))
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "pawprint.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text(reminder.patientName)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(reminder.task)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Label(reminder.clientName, systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(reminder.dueDateFormatted, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(reminder.isOverdue ? .red : .secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .leading) {
            Button(action: {
                reminderManager.snoozeReminder(reminder)
            }) {
                Label("Snooze", systemImage: "clock")
            }
            .tint(.orange)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: {
                reminderManager.deleteReminder(reminder)
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .contextMenu {
            Button(action: {
                reminderManager.completeReminder(reminder)
            }) {
                Label("Mark Complete", systemImage: "checkmark.circle")
            }
            
            Button(action: {
                reminderManager.snoozeReminder(reminder, by: 1)
            }) {
                Label("Snooze 1 Day", systemImage: "clock")
            }
            
            Button(action: {
                reminderManager.addToCalendar(reminder)
            }) {
                Label("Add to Calendar", systemImage: "calendar.badge.plus")
            }
            
            Button(action: {
                // Call client
                if let url = URL(string: "tel://") {
                    UIApplication.shared.open(url)
                }
            }) {
                Label("Call \(reminder.clientName)", systemImage: "phone.fill")
            }
        }
    }
}

// MARK: - Empty State

struct EmptyRemindersView: View {
    @Binding var showingNewReminder: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Follow-ups Scheduled")
                .font(.title2.bold())
            
            Text("Create reminders to never forget a patient check-in")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showingNewReminder = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Reminder")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
            }
        }
        .padding()
    }
}

// MARK: - New Reminder Sheet

struct NewReminderSheet: View {
    @ObservedObject var reminderManager: ReminderManager
    @Environment(\.dismiss) var dismiss
    
    @State private var patientName = ""
    @State private var clientName = ""
    @State private var task = ""
    @State private var dueDate = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Patient Information") {
                    TextField("Patient Name", text: $patientName)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Client Name", text: $clientName)
                        .textInputAutocapitalization(.words)
                }
                
                Section("Reminder Details") {
                    TextField("Task", text: $task)
                        .textInputAutocapitalization(.sentences)
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button("Create Reminder") {
                        reminderManager.createReminder(
                            patientName: patientName,
                            clientName: clientName,
                            task: task,
                            dueDate: dueDate,
                            notes: notes
                        )
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(patientName.isEmpty || task.isEmpty)
                }
            }
            .navigationTitle("New Follow-up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RemindersView()
}
