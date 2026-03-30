# LabySums
**Ett pedagogiskt dungeon-crawl där matematik är vapnet och logik är vägen ut.**

LabySums är ett passionsprojekt utvecklat i Godot 3 som föddes ur en vilja att göra mängdträning i matematik till något engagerande istället för repetitivt. Tanken är enkel: du navigerar en hjälte genom slumpmässigt genererade labyrinter i en top-down-vy, men istället för att fäktas med svärd måste du samla siffror och operatorer för att låsa upp dörrar.

[![Se demovideon för LabySums på YouTube](https://img.youtube.com/vi/g8Zaws0kTo8/0.jpg)](https://youtu.be/g8Zaws0kTo8)

## 🛠 Tekniska utmaningar och arkitektur
Under utvecklingens gång har fokus legat på att skapa ett system som är både skalbart och effektivt. Istället för att bara hårdkoda banor har jag arbetat med procedurell generering av labyrintsegment och uppgifter.

### Navigering och AI
En av de största utmaningarna var att få fienderna att kännas levande i en labyrintmiljö. Jag implementerade en gemensam basklass för all programmatisk rörelse och utvecklade logik för att göra fiender medvetna om sidogångar och rutter. För boss-striderna har jag byggt en **State Machine** som hanterar komplexare beteenden och rörelsemönster.

### Optimering och datastruktur
För att hålla nere resursanvändningen vid generering av stora banor lagras kartorna som **binära arrayer**. Jag har även lagt tid på att refakturera projektets "Task Creator" – den motor som genererar de matematiska problemen – för att säkerställa att svårighetsgraden kan anpassas (t.ex. genom att begränsa till enbart additiva operatorer).

### UI och användarupplevelse
Eftersom spelet har ett pedagogiskt syfte har stor vikt lagts vid feedback-loopar. Detta inkluderar dynamiska GUI-etiketter för målsiffror och ett system som sömlöst laddar nästa segment när en nivå slutförts.

## 📈 Projektstatus och arbetsflöde
Projektet har drivits med ett tydligt fokus på iterativ utveckling. Genom att använda **GitHub Projects (Kanban)** har jag kunnat prioritera buggfixar (som att lösa problem med aktörer som hamnat utanför linjeringen) och planera framtida funktioner som dynamisk storlek på labyrintsegment och förbättrad kamera-hantering.

**Nuvarande fokus:**
*   Polering av startmenyn och användargränssnittet.
*   Förbättring av algoritmerna för rutt-generering.
*   Utbyggnad av animations-systemet för spelaren.

## 💻 Tech Stack
*   **Motor:** Godot Engine 3.
*   **Språk:** GDScript.
*   **Planering:** GitHub Projects / Kanban.
