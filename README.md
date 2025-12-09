# Cureonix – Pharma Intelligence App

A Flutter-based Pharma Intelligence application powered by **Gemini 2.5 Flash**.

## Features

- **7 Specialized Agents**: IQVIA Insights, EXIM Trends, Patent Landscape, Clinical Trials, Internal Knowledge, Web Intelligence, Report Generator.
- **Gemini 2.5 Flash Integration**: Directly calls the Gemini API (configurable).
- **Structured Outputs**: Displays JSON data as formatted tables and summaries.
- **History & Settings**: Save queries and configure API keys.

## Getting Started

### Prerequisites
- Flutter SDK installed.
- Valid Google AI Studio API Key.

### Setup

1.  Navigate to the project directory:
    ```bash
    cd cureonix_app
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run
    ```

### Configuration
1.  Launch the app.
2.  Go to **Settings** (Gear icon on Dashboard).
3.  Enter your **Gemini API Key**.
4.  Ensure Model ID is set to `gemini-2.5-flash` (or `gemini-1.5-flash` if 2.5 is not yet enabled for your account).

## Project Structure
- `lib/config/agents.dart`: System prompts for all agents.
- `lib/services/gemini_service.dart`: API communication.
- `lib/screens/`: UI logic.
- `lib/providers/app_state.dart`: State management.
