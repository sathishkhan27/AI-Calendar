# 📅 AI Calendar - Cross-Platform Responsive App (Desktop & Mobile)

A production-grade, responsive Flutter application designed for **Desktop (macOS, Windows, Linux)** and **Mobile (Android, iOS, Web)**. It seamlessly aggregates events and scheduled calls from **Gmail / Google Calendar / Google Meet** and **Outlook / Microsoft Teams**, powered by an **AI Executive Briefing Engine**.

---

## 🌟 Key Features

### 1. 📬 Dual Account & Call Ingestion
- **Google Calendar & Meet**: Automatically syncs calendar events and extracts Google Meet links (`https://meet.google.com/...`) with participant information.
- **Microsoft Outlook & Teams**: Syncs calendar invites and extracts Microsoft Teams links (`https://teams.microsoft.com/...`) with organizer and attendee details.
- **Client-Side Direct OAuth2**: Connects directly via Google Calendar REST API v3 and Microsoft Graph API v1.0 without intermediary data brokers.
- **1-Click Demo & Live Sync**: Includes realistic mock data out of the box so you can run the app immediately, plus live OAuth credential configuration in Settings.

### 2. 🤖 AI Daily Executive Briefing & Smart Scheduling
- **Daily Briefing**: Synthesizes meetings, detects tight schedule turnarounds, calculates dedicated focus time vs. meeting duration, and surfaces actionable prep notes.
- **Overlap & Conflict Detection**: Identifies double-booked sessions across Google and Outlook with instant alert banners.
- **Natural Language Event Creation**: Schedule meetings simply by typing:
  > *"Schedule a 45 min design review tomorrow at 3pm on Google Meet"*
- **Gemini AI Integration**: Uses Google Gemini API (`gemini-1.5-flash`) for real-time generative summaries, with an intelligent offline heuristic engine when no API key is set.

### 3. 🖥️📱 True Adaptive Responsive Layout
- **Desktop & Tablet (`> 768px`)**:
  - Left Collapsible Sidebar with account toggles, navigation, mini date picker, and quick stats.
  - Main Central Agenda with weekly day-strip, call filters, and event timelines.
  - Right Executive AI Panel with live briefing metrics and instant natural language scheduler.
- **Mobile (`<= 768px`)**:
  - Top Date strip and search bar.
  - Interactive agenda cards with 1-tap "Join Call Now" buttons.
  - Bottom Navigation Bar (Calendar, Scheduled Calls, AI Briefing, Accounts).
  - Floating Action Button for AI quick scheduling.

### 4. 📞 Dedicated Scheduled Calls Dashboard
- Direct **"Join Call Now"** button launching Google Meet, Microsoft Teams, or Zoom in your default browser or native app via `url_launcher`.
- Live Call countdowns (*"Happening now • 25m left"*, *"Starts in 15m"*).
- Attendee avatars, role badges, and AI prep notes.

---

## 🏗️ Project Architecture (MVVM & Repository Pattern)

```text
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart          # Slate 900 dark theme, indigo & AI violet palette
│   │   └── app_theme.dart           # Material 3 theme configurations
│   └── utils/
│       ├── date_time_utils.dart     # Formatting, relative times, countdowns
│       └── responsive_utils.dart    # Mobile/Tablet/Desktop breakpoint utilities
├── data/
│   ├── models/
│   │   ├── event_item.dart          # Event & Call model (Meet, Teams, Zoom, attendees)
│   │   ├── connected_account.dart   # Google & Microsoft accounts and sync statuses
│   │   └── daily_briefing.dart      # AI executive summaries, metrics, and action items
│   ├── services/
│   │   ├── google_calendar_service.dart   # Google Calendar REST API v3 client
│   │   ├── microsoft_outlook_service.dart # Microsoft Graph API v1.0 client
│   │   ├── gemini_ai_service.dart         # Gemini LLM + local heuristic parser
│   │   └── storage_service.dart           # SharedPreferences local persistence
│   └── repositories/
│       └── calendar_repository.dart       # Single source of truth for all events & calls
├── ui/
│   ├── view_models/
│   │   ├── calendar_view_model.dart       # State management for calendar views & filters
│   │   ├── ai_briefing_view_model.dart    # State for executive briefing & NL scheduler
│   │   └── accounts_view_model.dart       # State for connected accounts & OAuth credentials
│   └── views/
│       ├── adaptive_shell.dart            # Responsive LayoutBuilder shell
│       ├── calendar_view.dart             # Agenda timeline & date navigator
│       ├── calls_view.dart                # Dedicated Scheduled Calls dashboard
│       ├── ai_briefing_view.dart          # AI Intelligence center & NL prompt bar
│       ├── accounts_view.dart             # Sync management & API key settings
│       └── widgets/
│           ├── sidebar_navigation.dart    # Desktop sidebar
│           ├── meeting_call_card.dart     # Call card with direct "Join Call"
│           ├── event_card.dart            # Calendar item card with source colors
│           ├── daily_briefing_card.dart   # AI Briefing executive widget
│           └── add_event_dialog.dart      # Dual mode: AI Prompt & Manual form
└── main.dart                              # Dependency injection & App entrypoint
```

---

## 🚀 How to Run

### 1. Web (Instant Desktop Browser Experience)
```bash
cd /Users/sathish.s/.gemini/antigravity-ide/scratch/ai_calendar_app
flutter run -d chrome
```

### 2. macOS Desktop
```bash
flutter run -d macos
```

### 3. Mobile (iOS / Android Simulator)
```bash
# Check connected simulators or physical devices
flutter devices

# Run on selected device
flutter run -d <device_id>
```

---

## ⚙️ Account Sync & API Keys Configuration

1. In the app, navigate to **Accounts & Sync**.
2. **Google & Outlook**: Both accounts are pre-configured with realistic sample synced events so you can test immediately. You can toggle sync on/off or connect additional accounts.
3. **Gemini AI**: In **Accounts & Sync -> Gemini AI Configuration**, you can paste your Google Gemini API key to enable live LLM executive briefings. If left blank, the built-in intelligent offline engine runs seamlessly.
