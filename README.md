# EasyQuit

EasyQuit is a simple and efficient application designed to help users quickly exit or close applications on their computer. With just a double click, users can terminate a application, saving time and effort.

## Features

### Core Funktionalität
- **Doppelklick-Beendigung**: Schließt eine Anwendung normal mit einem Doppelklick (graceful quit).
- **Rechtsklick Force Quit**: Kontextmenü mit der Option "Force Quit" für hängende oder nicht reagierende Apps.
- **Benutzerfreundliche Oberfläche**: Einfach zu navigieren und zu verwenden.
    - **Suchleiste** oben: Schnelles Finden von Anwendungen durch Live-Suche.
    - **App-Liste** darunter: Übersicht aller aktuell laufenden Anwendungen.
- **Leichtgewichtig**: Minimaler Ressourcenverbrauch.

### Zusätzliche Features (zur Diskussion)

#### App-Informationen
- **App-Icons**: Zeige nur das Icon jeder laufenden Anwendung für bessere Übersicht (kein Text).

#### Intelligente Funktionen
- **App-Status-Indikator** (nur visuell): 
  - App läuft normal: normales app icon
  - App reagiert langsam: app icon mit gelbem Warnsymbol
  - App reagiert nicht: app icon mit rotem Warnsymbol (automatisch Force Quit vorschlagen)
- **Geschützte Apps**: Systemkritische Apps ausblenden (Finder, etc.)
- **Mehrfachauswahl**: Mit Cmd+Klick mehrere Apps auswählen und gleichzeitig beenden

#### Kontextmenü-Optionen (Rechtsklick)
- **Force Quit**: Erzwungenes Beenden
- **App neu starten**: Beenden und sofort wieder öffnen
- **Im Finder anzeigen**: Zeigt den Speicherort der Anwendung
- **Weitere Fenster anzeigen**: Liste aller offenen Fenster dieser App
- **Ignorieren**: App aus der Liste temporär ausblenden

#### Visuelle Features
- **Dark/Light Mode**: Automatische Anpassung an System-Einstellungen
- **Live-Updates**: Liste aktualisiert sich automatisch wenn Apps gestartet/beendet werden
- **Animationen**: Sanfte Übergänge beim Entfernen von Apps aus der Liste

#### Einstellungen
- **Aktualisierungsintervall**: Wie oft wird die App-Liste aktualisiert? (1s, 2s, 5s)
- **Ausgeblendete Apps**: Welche System-Apps sollen nicht angezeigt werden?
- **Standard-Aktion**: Doppelklick = Quit oder Force Quit?
- **Warnungen**: Welche Bestätigungen sollen angezeigt werden?
- **Erscheinungsbild**: Farbschema, Schriftgröße, kompakte vs. detaillierte Ansicht
- **Statistiken**: 
  - Welche Apps werden am häufigsten beendet?
  - Durchschnittliche Laufzeit vor Beendigung

## Usage

### Basis-Nutzung
1. Starte EasyQuit.
2. **Doppelklick** auf eine App = normale Beendigung (graceful quit).
3. **Rechtsklick** auf eine App = Kontextmenü mit "Force Quit" Option.
4. Die App wird sofort beendet.

### Erweiterte Nutzung
- **Suchen**: Tippe in die Suchleiste, um Apps schnell zu finden.
- **Mehrfachauswahl**: Halte `Cmd` und klicke mehrere Apps an.
- **Tastatursteuerung**: Nutze Pfeiltasten zur Navigation und `Enter` zum Beenden.
