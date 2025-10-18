#!/bin/bash

echo "🐴 Creating Notalyze Export Package..."

# Create export directory
mkdir -p NotalyzeExport/Source
mkdir -p NotalyzeExport/Documentation

# Copy Swift files
echo "📄 Copying Swift files..."
cp *.swift NotalyzeExport/Source/ 2>/dev/null

# Copy documentation
echo "📚 Copying documentation..."
cp *.md NotalyzeExport/Documentation/ 2>/dev/null

# Copy config files
echo "⚙️  Copying config files..."
cp Info.plist NotalyzeExport/Source/ 2>/dev/null

# Create file list
echo "📋 Creating file manifest..."
cat > NotalyzeExport/FILE_LIST.txt << 'FILELIST'
NOTALYZE - Complete File List
================================

SWIFT SOURCE FILES (23 files):
├── NotalyzeApp.swift
├── MainTabView.swift
├── ConsultationsListView.swift
├── ConsultationDetailView.swift
├── RecordView.swift
├── AIAssistantView.swift
├── CallRecordingView.swift
├── PhoneConsultationDetailView.swift
├── RemindersView.swift
├── TemplatesView.swift
├── NewConsultationSheet.swift
├── EstimateView.swift
├── OfflineIndicatorView.swift
├── SettingsView.swift
├── Models.swift
├── ConsultationManager.swift
├── AudioRecorder.swift
├── CallManager.swift
├── AIAssistantManager.swift
├── EstimateGenerator.swift
├── OfflineManager.swift
└── ReminderManager.swift

CONFIGURATION:
├── Info.plist

DOCUMENTATION (6 files):
├── README.md
├── DEVELOPER_HANDOFF.md ⭐ START HERE
├── PHONE_CALL_SETUP.md
├── AI_ASSISTANT_GUIDE.md
├── ESTIMATE_GENERATION_GUIDE.md
└── EXPORT_INSTRUCTIONS.md

TOTAL: 30 files
FILELIST

# Count files
SWIFT_COUNT=$(ls -1 NotalyzeExport/Source/*.swift 2>/dev/null | wc -l)
DOC_COUNT=$(ls -1 NotalyzeExport/Documentation/*.md 2>/dev/null | wc -l)

echo ""
echo "✅ Export Complete!"
echo "   Swift files: $SWIFT_COUNT"
echo "   Documentation: $DOC_COUNT"
echo ""
echo "📦 Ready to share: NotalyzeExport/"
echo ""
echo "Next steps:"
echo "  1. Review NotalyzeExport/Documentation/DEVELOPER_HANDOFF.md"
echo "  2. ZIP the folder: zip -r Notalyze.zip NotalyzeExport/"
echo "  3. Send to your team!"
echo ""
