import 'package:flutter/material.dart';
import 'dart:ui';


void main() {
  runApp(MyApp());
}

class Player {
  String name;
  int points;
  bool isSelectable;
  bool isVisible;
  bool isSelected; // Für den ausgewählten Spieler im Dropdown-Menü
  bool hasRedDot; // Für den roten Punkt im GridView
  int totalPoints;

  Player(this.name, this.points, this.isSelectable, {this.isVisible = true, this.isSelected = false, this.hasRedDot = false, this.totalPoints = 0});
}

class PointsOption {
  String label;
  int value;

  PointsOption(this.label, this.value);

  static PointsOption plusOne() {
    return PointsOption('+1', 1);
  }

  static PointsOption plusTwo() {
    return PointsOption('+2', 2);
  }

  static PointsOption plusThree() {
    return PointsOption('+3', 3);
  }

  static PointsOption plusFour() {
    return PointsOption('+4', 4);
  }
}

class PointsMultiplier {
  String label;
  int multiplier;

  PointsMultiplier(this.label, this.multiplier);
}

class RoundResult {
  int roundNumber;
  Map<String, int> playerPoints;

  RoundResult(this.roundNumber, this.playerPoints);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Player> players = [];
  int selectedPlayerCount = 3;
  bool pointsGiven = false; // Neue Variable für den Zustand der Punktevergabe
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('SPIELERAUSWAHL'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 3; i <= 5; i++)
                  ElevatedButton(
                    onPressed: () async {
                      // Setze die ausgewählte Spieleranzahl
                      setState(() {
                        selectedPlayerCount = i;
                      });

                      // Lasse die Spieler benennen
                      await _getPlayersNames(i);

                      // Navigiere zur nächsten Seite
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayersTablePage(players),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPlayerCount == i ? Colors.blue[200] : Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                        side: BorderSide(color: Colors.black, width: 2.0), // Fügt den schwarzen Rahmen hinzu
                      ),
                    ),
                    child: Text(
                      '$i', // Änderung des Textes
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _getPlayersNames(int playerCount) async {
    List<Player> selectedPlayers = [];

    for (int i = 0; i < playerCount; i++) {
      String? playerName = await _getPlayerName(context, i + 1);
      selectedPlayers.add(Player(playerName?.toUpperCase() ?? 'SPIELER ${i + 1}', 15, true));
    }

    setState(() {
      players = selectedPlayers;
    });
  }

  Future<String?> _getPlayerName(BuildContext context, int playerNumber) async {
    TextEditingController controller = TextEditingController();

    // Hier wird das UI für die Spielerbenennung direkt in der Spielerauswahl erstellt
    // und der TextEditingController verwendet, um den eingegebenen Namen zu erhalten.

    // Rückgabe des eingegebenen Spielernamens durch einen Dialog
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent, // Hintergrundfarbe des Dialogs transparent
          content: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white, // Hintergrundfarbe des Inhalts des Dialogs
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Spieler $playerNumber', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10.0),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Name des Spielers eingeben',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    Navigator.pop(context, value); // Schließe den Dialog und gebe den eingegebenen Namen zurück
                  },
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Schließe den Dialog, ohne einen Namen zurückzugeben
                      },
                      child: Text('Abbrechen'),
                    ),
                    SizedBox(width: 10.0),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, controller.text); // Schließe den Dialog und gebe den eingegebenen Namen zurück
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class PlayersTablePage extends StatefulWidget {
  final List<Player> players;

  PlayersTablePage(this.players);

  @override
  _PlayersTablePageState createState() => _PlayersTablePageState();
}

class _PlayersTablePageState extends State<PlayersTablePage> {
  Player? selectedPlayer;
  PointsOption? selectedPointsOption;
  PointsMultiplier? selectedMultiplier;
  int calculatedPoints = 0;
  int roundNumber = 1;
  List<RoundResult> roundResults = [];
  String? selectedValue;
  int currentRound = 1; // Hinzugefügte Variable für die Rundenanzeige
  Player? selectedDropdownPlayer;
  Player? selectedGridViewPlayer;

  List<PointsOption> pointsOptions = [
    PointsOption('-5', -5),
    PointsOption('-4', -4),
    PointsOption('-3', -3),
    PointsOption('-2', -2),
    PointsOption('-1', -1),
  ];

  List<PointsMultiplier> pointsMultipliers = [
    PointsMultiplier('x1', 1),
    PointsMultiplier('x2', 2),
    PointsMultiplier('x4', 4),
    PointsMultiplier('x8', 8),
    PointsMultiplier('x16', 16),
    PointsMultiplier('x32', 32),
    PointsMultiplier('x64', 64),
  ];

  @override
  void initState() {
    super.initState();
    // Set the default multiplier when the state is initialized
    selectedMultiplier = pointsMultipliers[0]; // Wähle den ersten Multiplikator aus
  }

  Map<String, int> calculateTotalPointsPerPlayer() {
    Map<String, int> totalPointsPerPlayer = {};

    for (var player in widget.players) {
      totalPointsPerPlayer[player.name] = 0;
    }

    for (var roundResult in roundResults) {
      for (var entry in roundResult.playerPoints.entries) {
        // Berücksichtige nur Punkte ab 0 (+-1)
        if (entry.value >= 0) {
          totalPointsPerPlayer[entry.key] = (totalPointsPerPlayer[entry.key] ?? 0) + entry.value;
        }
      }
    }

    // Sortiere die Spieler basierend auf ihren Gesamtpunkten in aufsteigender Reihenfolge
    var sortedPlayers = totalPointsPerPlayer.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Erstelle eine neue Map mit sortierten Einträgen
    Map<String, int> sortedTotalPointsPerPlayer = {};
    for (var entry in sortedPlayers) {
      sortedTotalPointsPerPlayer[entry.key] = entry.value;
    }

    return sortedTotalPointsPerPlayer;
  }

  void _editPoints(Player player) async {
    TextEditingController controller = TextEditingController();
    controller.text = player.points.toString();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Punktestand bearbeiten"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Neuer Punktestand"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Schließe den Dialog
              },
              child: Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () {
                // Überprüfe, ob die Eingabe gültig ist
                if (controller.text.isNotEmpty) {
                  int newPoints = int.parse(controller.text);
                  setState(() {
                    player.points = newPoints;
                    // Optional: Füge hier die Aktualisierung der Gesamtpunktzahl hinzu
                  });
                }
                Navigator.of(context).pop(); // Schließe den Dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text("Speichern"),
            ),
          ],
        );
      },
    );
  }

  void resetPoints() {
    setState(() {
      for (var player in widget.players) {
        player.points = 15;
      }
    });
  }

  void endRound() {
    Map<String, int> playerPoints = {};
    for (var player in widget.players) {
      playerPoints[player.name] = player.points;
    }

    RoundResult roundResult = RoundResult(roundNumber, playerPoints);
    roundResults.add(roundResult);
    roundNumber++;

    resetPoints();
  }

  void resetRound() {
    setState(() {
      roundNumber = 1;
      roundResults.clear();
      resetPoints();

      // Multiplikator auf x1 zurücksetzen
      selectedMultiplier = pointsMultipliers[0];
      selectedValue = 'x${selectedMultiplier!.multiplier}';

      // Rundenanzahl zurücksetzen
      currentRound = 1;

      // Dropdown-Menü zurücksetzen und rote Markierung aufheben
      selectedDropdownPlayer = null;

      // Setze isSelected für alle Spieler zurück, um den roten Punkt im Dropdown-Menü zu entfernen
      // und den roten Punkt im GridView zu entfernen
      for (var player in widget.players) {
        player.isSelected = false;
        player.hasRedDot = false;
      }
    });
  }

  void showRoundResults() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.0),
                  Text(
                    'RUNDENERGEBNISSE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: roundResults.map((roundResult) {
                        return Container(
                          width: 150.0,
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'RUNDE ${roundResult.roundNumber}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                  fontSize: 20,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: roundResult.playerPoints.entries.map((entry) {
                                  var playerName = entry.key;
                                  var playerPoints = entry.value < 0 ? 0 : entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$playerName: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '${playerPoints.toString()}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Aktuelle Runde: $currentRound',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }





  void _applyMPlus() {
    if (selectedPlayer != null && selectedMultiplier != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(''),
            content: Text('Ist der Mula wirklich nicht durchgegangen?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyMPlusConfirmed();
                },
                child: Text('Bestätigen'),
              ),
            ],
          );
        },
      );
    }
  }

  void _applyMMinus() {
    if (selectedPlayer != null && selectedMultiplier != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Ist der Mula wirklich durchgegangen?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyMMinusConfirmed();
                },
                child: Text('Bestätigen'),
              ),
            ],
          );
        },
      );
    }
  }


  void _applyMPlusConfirmed() {
    // Überprüfen, ob kein Spieler auf 0 oder weniger Punkte fällt
    if (!widget.players.any((player) => player.points <= 0)) {
      setState(() {
        selectedPlayer!.points += 20 * selectedMultiplier!.multiplier;

        // Den restlichen Spielern -20 Punkte hinzufügen
        for (var player in widget.players) {
          if (player != selectedPlayer) {
            player.points -= 20 * selectedMultiplier!.multiplier;
            if (player.points <= 0) {
              player.points = 0;
            }
          }
        }

        // Multiplikator auf x1 zurücksetzen
        selectedMultiplier = pointsMultipliers[0];
        selectedValue = 'x${selectedMultiplier!.multiplier}';
      });

      // Überprüfen, ob ein Spieler 0 Punkte oder weniger hat
      bool anyPlayerBelowZero = widget.players.any((player) => player.points <= 0);

      // Wenn kein Spieler 0 oder weniger Punkte hat, wähle automatisch den nächsten Spieler im Uhrzeigersinn aus
      if (!anyPlayerBelowZero) {
        _automaticallySelectNextPlayer();
      } else {
        // Starte automatisch eine neue Runde, da ein Spieler auf 0 oder weniger Punkte fällt
        endRound();
        setState(() {
          currentRound++;
        });
        startNewRound(); // Neue Runde starten
      }
    } else {
      // Hier können Sie eine Benachrichtigung oder eine Meldung anzeigen, dass keine Änderungen möglich sind, da ein Spieler auf 0 oder weniger Punkte fällt.
    }
  }

  void _applyMMinusConfirmed() {
    // Überprüfen, ob kein Spieler auf 0 oder weniger Punkte fällt
    if (!widget.players.any((player) => player.points <= 0)) {
      setState(() {
        selectedPlayer!.points -= 20 * selectedMultiplier!.multiplier;
        if (selectedPlayer!.points <= 0) {
          selectedPlayer!.points = 0;
        }

        // Den restlichen Spielern +20 Punkte hinzufügen
        for (var player in widget.players) {
          if (player != selectedPlayer) {
            player.points += 20 * selectedMultiplier!.multiplier;
            if (player.points <= 0) {
              player.points = 0;
            }
          }
        }

        // Multiplikator auf x1 zurücksetzen
        selectedMultiplier = pointsMultipliers[0];
        selectedValue = 'x${selectedMultiplier!.multiplier}';
      });

      // Überprüfen, ob ein Spieler 0 Punkte oder weniger hat
      bool anyPlayerBelowZero = widget.players.any((player) => player.points <= 0);

      // Wenn kein Spieler 0 oder weniger Punkte hat, wähle automatisch den nächsten Spieler im Uhrzeigersinn aus
      if (!anyPlayerBelowZero) {
        _automaticallySelectNextPlayer();
      } else {
        // Starte automatisch eine neue Runde, da ein Spieler auf 0 oder weniger Punkte fällt
        endRound();
        setState(() {
          currentRound++;
        });
        startNewRound(); // Neue Runde starten
      }
    } else {
      // Hier können Sie eine Benachrichtigung oder eine Meldung anzeigen, dass keine Änderungen möglich sind, da ein Spieler auf 0 oder weniger Punkte fällt.
    }
  }








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('W E L I'),
        actions: [
          ElevatedButton(
            onPressed: () {
              _showPrizeMoneyDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300], // Hintergrundfarbe des Buttons
              foregroundColor: Colors.black, // Textfarbe des Buttons
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0), // Eckiger Rand
                side: BorderSide(color: Colors.black),
              ),
              minimumSize: Size(120, 40), // Festlegen der Mindestgröße des Buttons
            ),
            child: Text(
              'SCHULDEN',
              style: TextStyle(fontSize: 16), // Stil des Textes
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showRoundResults();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300], // Hintergrundfarbe des Buttons
              foregroundColor: Colors.black, // Textfarbe des Buttons
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0), // Eckiger Rand
                side: BorderSide(color: Colors.black),
              ),
              minimumSize: Size(120, 40), // Festlegen der Mindestgröße des Buttons
            ),
            child: Text(
              'RUNDEN',
              style: TextStyle(fontSize: 16), // Stil des Textes
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Anzeige der aktuellen Rundenanzahl
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Runde: $currentRound',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Dropdown-Menü
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: selectedDropdownPlayer != null ? SizedBox.shrink() : DropdownButton<Player>(
              value: selectedDropdownPlayer,
              onChanged: (Player? newValue) {
                setState(() {
                  // Setze den ausgewählten Spieler im Dropdown-Menü
                  selectedDropdownPlayer = newValue;

                  // Setze isSelected für alle Spieler zurück
                  for (var player in widget.players) {
                    player.isSelected = false;
                  }

                  // Setze isSelected nur für den ausgewählten Spieler
                  if (newValue != null) {
                    newValue.isSelected = true;

                    // Aktualisiere den roten Punkt für den ausgewählten Spieler im GridView
                    for (var player in widget.players) {
                      player.hasRedDot = (player == newValue);
                    }
                  }
                });
              },
              items: widget.players.map<DropdownMenuItem<Player>>((Player player) {
                return DropdownMenuItem<Player>(
                  value: player,
                  child: Container(
                    child: Row(
                      children: [
                        Text(
                          player.name,
                          style: TextStyle(
                            color: player.isSelected ? Colors.red : Colors.black, // Markiere den ausgewählten Spieler rot
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              icon: SizedBox.shrink(), // This line removes the icon
              underline: Container(), // This line removes the underline
            ),
          ),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 0.1,
                mainAxisSpacing: 0.1,
              ),
              itemCount: widget.players.length,
              itemBuilder: (context, index) {
                Player currentPlayer = widget.players[index];
                bool isSelected = selectedPlayer == currentPlayer;

                if (currentPlayer.isVisible) {
                  // Extrahiere das letzte Rundenergebnis für den aktuellen Spieler
                  int lastRoundResult = roundResults.isNotEmpty ? roundResults.last.playerPoints[currentPlayer.name] ?? 0 : 0;

                  return IgnorePointer(
                    ignoring: !currentPlayer.isVisible,
                    child: InkWell(
                      onTapDown: (details) {
                        setState(() {
                          selectedPlayer = isSelected ? null : currentPlayer;
                        });
                      },
                      onLongPress: () {
                        _handleMinusButtonPress(currentPlayer);
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1.0,
                              ),
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    height: 105,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            // Hier wird der Dialog zum Bearbeiten des Punktestands geöffnet
                                            _editPoints(currentPlayer);
                                          },
                                          child: Text(
                                            '${currentPlayer.points}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 1),
                                        Row( // Row für die Anzeige der letzten Runde und der Gesamtpunkte
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$lastRoundResult', // Anzeige der letzten Runde
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(width: 10), // Abstand zwischen den Werten
                                            Text(
                                              '${calculateTotalPointsPerPlayer()[currentPlayer.name]}', // Anzeige der Gesamtpunkte
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 1),
                                        Text(
                                          currentPlayer.name,
                                          style: TextStyle(
                                            color: selectedDropdownPlayer == currentPlayer
                                                ? Colors.redAccent // Hier wird die Farbe geändert
                                                : Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Linke X-Taste
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: InkWell(
                                    onTap: () {
                                      _handleLeftXButtonPress(currentPlayer);
                                    },
                                    child: ClipOval(
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.black,
                                            size: 24.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Rechte X-Taste
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      _handleRightXButtonPress(currentPlayer);
                                    },
                                    child: ClipOval(
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.red,
                                            size: 24.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Roter Punkt in der Mitte zwischen den X-Tasten
                                Positioned(
                                  top: 15,
                                  left: 20, // Abstand vom linken X-Button
                                  right: 20, // Abstand vom rechten X-Button
                                  child: AnimatedContainer(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: currentPlayer.hasRedDot ? Colors.red : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    duration: Duration(milliseconds: 500), // Ändern Sie die Dauer nach Bedarf
                                    curve: Curves.easeInOut, // Ändern Sie die Kurve nach Bedarf
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showMultiplierMenu(context);
                },
                icon: Container(),
                label: Text(
                  selectedMultiplier != null
                      ? 'x${selectedMultiplier!.multiplier}'
                      : '*',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMultiplier != null
                      ? Colors.blue[200]
                      : Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _applyMPlus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMultiplier != null
                      ? Colors.redAccent
                      : Colors.redAccent[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  'M',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _applyMMinus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMultiplier != null
                      ? Colors.green
                      : Colors.green[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  'M',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-1', -1);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-1'
                      ? Colors.blue[200]
                      : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  '-1',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-2', -2);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-2'
                      ? Colors.blue[200]
                      : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  '-2',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-3', -3);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-3'
                      ? Colors.blue[200]
                      : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  '-3',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-4', -4);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-4'
                      ? Colors.blue[200]
                      : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  '-4',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-5', -5);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-5'
                      ? Colors.blue[200]
                      : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  '-5',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.only(bottom: 16.0, top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (selectedPlayer != null &&
                        selectedPointsOption != null &&
                        selectedMultiplier != null) {
                      _applyPointsToPlayer(
                          selectedPlayer!, selectedPointsOption!.value);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: Text(
                    'ÜBERNEHMEN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Text fett machen
                      fontSize: 17, // Textgröße ändern
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    endRound();
                    setState(() {
                      currentRound++;
                      startNewRound(); // Hier wird startNewRound() aufgerufen
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: Text(
                    'NEUE RUNDE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Text fett machen
                      fontSize: 17, // Textgröße ändern
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    resetRound();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Ändern Sie den Padding-Wert nach Bedarf
                    child: Icon(
                      Icons.refresh,
                      size: 24, // Ändern Sie die Symbolgröße nach Bedarf
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _showPrizeMoneyDialog(BuildContext context) {
    List<Player> sortedPlayers = List<Player>.from(widget.players);
    sortedPlayers.sort((a, b) => calculateTotalPointsPerPlayer()[b.name]!.compareTo(calculateTotalPointsPerPlayer()[a.name]!));

    Map<String, Map<String, double>> prizeMoneyMap = {};
    String selectedMultiplier = '0.05'; // Startwert für den Multiplikator

    // Berechnung des Preisgeldes mit dem Multiplikator 0,05
    _calculatePrizeMoney(sortedPlayers, prizeMoneyMap, selectedMultiplier);

    // Map für den Status der Checkboxen
    Map<String, Map<String, bool>> isCheckedMap = {};
    for (var entry in prizeMoneyMap.entries) {
      isCheckedMap[entry.key] = {};
      for (var innerEntry in entry.value.entries) {
        isCheckedMap[entry.key]![innerEntry.key] = false; // Setze den Standardwert für alle Checkboxen auf false
      }
    }

    // Anzeige des Preisgeld-Dialogs
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.transparent, // Transparenter Hintergrund
              child: SingleChildScrollView( // Scrollbare Ansicht hinzugefügt
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  color: Colors.white, // Weißer Hintergrund für den Container
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'SCHULDEN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Zentriertes Dropdown-Widget für die Auswahl des Multiplikators
                      Container(
                        alignment: Alignment.center,
                        child: DropdownButton<String>(
                          value: selectedMultiplier,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMultiplier = newValue!;
                              // Nach dem Ändern des Multiplikators die Beträge neu berechnen und aktualisieren
                              _calculatePrizeMoney(sortedPlayers, prizeMoneyMap, selectedMultiplier);
                            });
                          },
                          dropdownColor: Colors.white, // Weißer Hintergrund für das Dropdown-Menü
                          items: <String>['0.05', '0.10', '0.15', '0.20'].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value + ' Cent'),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: prizeMoneyMap.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key} an',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: entry.value.entries.map((innerEntry) {
                                  String playerName = innerEntry.key;
                                  bool isChecked = isCheckedMap[entry.key]![playerName] ?? false; // Status der Checkbox

                                  return Row(
                                    children: [
                                      Text(
                                        '$playerName ',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward), // Icon anstelle des Pfeils
                                      Text(
                                        ' ${innerEntry.value.abs().toInt()} €', // Eurobetrag
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, // Fett für den Betrag
                                          fontSize: 16,
                                        ),
                                      ),
                                      Checkbox(
                                        value: isChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isCheckedMap[entry.key]![playerName] = value ?? false; // Update des Status der Checkbox
                                          });
                                        },
                                        activeColor: Colors.green, // Farbe für das grüne X
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }



// Funktion zur Berechnung des Preisgeldes mit dem ausgewählten Multiplikator
  void _calculatePrizeMoney(List<Player> sortedPlayers, Map<String, Map<String, double>> prizeMoneyMap, String selectedMultiplier) {
    prizeMoneyMap.clear();
    for (int i = 0; i < sortedPlayers.length - 1; i++) {
      Player player1 = sortedPlayers[i];
      for (int j = i + 1; j < sortedPlayers.length; j++) {
        Player player2 = sortedPlayers[j];
        double difference = (calculateTotalPointsPerPlayer()[player2.name]! - calculateTotalPointsPerPlayer()[player1.name]!) * double.parse(selectedMultiplier);
        difference = difference.roundToDouble();

        if (prizeMoneyMap.containsKey(player1.name)) {
          prizeMoneyMap[player1.name]![player2.name] = difference;
        } else {
          prizeMoneyMap[player1.name] = {player2.name: difference};
        }
      }
    }
  }





  void startNewRound() {
    // Finde den Index des aktuellen ausgewählten Spielers mit rotem Namen
    int currentIndexName = selectedDropdownPlayer != null ? widget.players.indexOf(selectedDropdownPlayer!) : -1;

    // Berechne den Index des nächsten Spielers im Uhrzeigersinn für den roten Namen
    int nextIndexName = (currentIndexName + 1) % widget.players.length;

    // Wähle den nächsten Spieler für den roten Namen aus und aktualisiere den Zustand
    setState(() {
      // Setze die rote Markierung für den aktuellen Spieler zurück
      if (selectedDropdownPlayer != null) {
        selectedDropdownPlayer!.isSelected = false;
      }

      // Wähle den nächsten Spieler für den roten Namen aus und setze die rote Markierung
      selectedDropdownPlayer = widget.players[nextIndexName];
      selectedDropdownPlayer!.isSelected = true;
    });

    // Finde den Index des aktuellen Spielers mit dem roten Punkt
    int currentIndexDot = widget.players.indexWhere((player) => player.hasRedDot);

    // Berechne den Index des nächsten Spielers im Uhrzeigersinn für den roten Punkt
    int nextIndexDot = (currentIndexDot + 1) % widget.players.length;

    // Setze den roten Punkt für alle Spieler zurück
    for (var player in widget.players) {
      player.hasRedDot = false;
    }

    // Wähle den nächsten Spieler für den roten Punkt aus und aktualisiere den Zustand
    setState(() {
      // Wähle den nächsten Spieler für den roten Punkt aus und setze den roten Punkt
      widget.players[nextIndexDot].hasRedDot = true;

      // Setze den roten Namen auf den Spieler mit dem roten Punkt
      selectedDropdownPlayer = widget.players[nextIndexDot];
      selectedDropdownPlayer!.isSelected = true;
    });
  }




  void _automaticallySelectNextPlayer() {
    // Finde den Index des aktuellen ausgewählten Spielers
    int currentIndex = selectedDropdownPlayer != null ? widget.players.indexOf(selectedDropdownPlayer!) : -1;

    // Berechne den Index des nächsten Spielers im Uhrzeigersinn
    int nextIndex = (currentIndex + 1) % widget.players.length;

    // Wähle den nächsten Spieler aus und aktualisiere den Zustand
    setState(() {
      selectedDropdownPlayer = widget.players[nextIndex];
      selectedGridViewPlayer = selectedDropdownPlayer; // Optional: Update auch den im GridView ausgewählten Spieler
    });
  }

  void _handleLeftXButtonPress(Player player) {
    if (!player.isVisible) return; // If player is hidden, do nothing
    // Handle the click on the left X for the specified player
    setState(() {
      player.points += 5 * selectedMultiplier!.multiplier;
      calculatedPoints = player.points;
      player.isVisible = false; // Hide player after adding points
    });

    // Check if all players are hidden
    if (widget.players.every((player) => !player.isVisible)) {
      // If all players are hidden, automatically show them again and reset multiplier to x1
      setState(() {
        for (var player in widget.players) {
          player.isVisible = true;
        }
        selectedMultiplier = pointsMultipliers[0];
        selectedPointsOption = null;
      });
    }
  }

  void _handleRightXButtonPress(Player player) {
    if (!player.isVisible) return; // If player is hidden, do nothing
    // Handle the click on the right X for the specified player
    setState(() {
      player.points += 10 * selectedMultiplier!.multiplier;
      calculatedPoints = player.points;
      player.isVisible = false; // Hide player after adding points
    });

    // Check if all players are hidden
    if (widget.players.every((player) => !player.isVisible)) {
      // If all players are hidden, automatically show them again and reset multiplier to x1
      setState(() {
        for (var player in widget.players) {
          player.isVisible = true;
        }
        selectedMultiplier = pointsMultipliers[0];
        selectedPointsOption = null;
      });
    }
  }

  void _handleMinusButtonPress(Player player) {
    // Behandle den Klick auf den Minus-Button für den angegebenen Spieler
    // Füge +1 Punkt zum Spieler unter Berücksichtigung des ausgewählten Multiplikators hinzu
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += 1 * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;
        player.isVisible = false; // Spieler ausblenden
      });

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein und setze den Multiplikator auf x1 zurück
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }

          // Multiplikator auf x1 zurücksetzen
          selectedMultiplier = pointsMultipliers[0];
          selectedValue = 'x${selectedMultiplier!.multiplier}';

          // Automatisch den nächsten Spieler im Uhrzeigersinn auswählen
          _automaticallySelectNextPlayer();
        });
      }
    }
  }

  void _applyPointsToPlayer(Player player, int points) {
    // Füge Punkte zum Spieler hinzu unter Berücksichtigung des Multiplikators
    if (player != null && selectedMultiplier != null && player.isVisible) {
      setState(() {
        player.points += points * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;

        // Stelle sicher, dass kein Spieler unter 0 Punkte fällt
        if (player.points < 0) {
          player.points = 0;
        }
        player.isVisible = false; // Spieler ausblenden
      });

      // Aktualisiere die Gesamtpunktzahl des Spielers
      updateTotalPoints(player);

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein und setze den Multiplikator auf x1 zurück
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }
          // Multiplikator auf x1 zurücksetzen
          selectedMultiplier = pointsMultipliers[0];
        });

        // Automatisch den nächsten Spieler im Uhrzeigersinn auswählen
        _automaticallySelectNextPlayer();
      }
    }
  }


  void updateTotalPoints(Player player) {
    // Aktualisiere die Gesamtpunktzahl des Spielers
    Map<String, int> totalPointsPerPlayer = calculateTotalPointsPerPlayer();
    int totalPoints = totalPointsPerPlayer[player.name] ?? 0;
    totalPoints += calculatedPoints;

    // Stelle sicher, dass keine Minuspunkte für die Gesamtpunktzahl angezeigt werden
    totalPoints = totalPoints < 0 ? 0 : totalPoints;

    totalPointsPerPlayer[player.name] = totalPoints;

    // Setze die Gesamtpunktzahl für jeden Spieler neu
    setState(() {
      totalPointsPerPlayer = totalPointsPerPlayer;

      // Hier wird der aktuelle Punktestand zum totalPoints der Spieler hinzugefügt
      player.totalPoints = totalPoints;
    });
  }


  void _showMultiplierMenu(BuildContext context) {
    setState(() {
      // Hier wird der Index des aktuellen Multiplikators gefunden
      int currentIndex = pointsMultipliers.indexOf(selectedMultiplier!);

      // Hier wird der Index des nächsten Multiplikators berechnet
      int nextIndex = (currentIndex + 1) % pointsMultipliers.length;

      // Hier wird der nächste Multiplikator ausgewählt
      selectedMultiplier = pointsMultipliers[nextIndex];
      selectedValue = 'x${selectedMultiplier!.multiplier}';
    });
  }
}