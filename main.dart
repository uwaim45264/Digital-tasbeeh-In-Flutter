import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() => runApp(TasbeehApp());

class TasbeehApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.teal,
        colorScheme: const ColorScheme.light(primary: Colors.teal),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.teal,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
      ),
      home: TasbeehHomePage(),
    );
  }
}

class TasbeehHomePage extends StatefulWidget {
  @override
  _TasbeehHomePageState createState() => _TasbeehHomePageState();
}

class _TasbeehHomePageState extends State<TasbeehHomePage> with TickerProviderStateMixin {
  int _tasbeehCount = 0;
  List<int> _tasbeehHistory = [];
  AnimationController? _controller;
  AnimationController? _bounceController;
  Animation<double>? _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedHistory();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bounceAnimation = CurvedAnimation(parent: _bounceController!, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _bounceController?.dispose();
    super.dispose();
  }

  void _incrementCount() {
    setState(() {
      _tasbeehCount++;
      _controller?.forward(from: 0.0);
      _bounceController?.forward(from: 0.0);
    });
    // Simple haptic feedback for satisfaction
    HapticFeedback.vibrate();
  }

  Future<void> _resetCount() async {
    bool? resetConfirmed = await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        return Center(
          child: _buildResetDialog(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );

    if (resetConfirmed == true) {
      setState(() {
        _tasbeehCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Count reset successfully')),
      );
    }
  }

  Future<void> _saveCount() async {
    bool? saveConfirmed = await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        return Center(
          child: _buildSaveDialog(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );

    if (saveConfirmed == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _tasbeehHistory.add(_tasbeehCount);
      });
      await prefs.setStringList(
        'tasbeehHistory',
        _tasbeehHistory.map((e) => e.toString()).toList(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Count saved successfully')),
      );
    }
  }

  Widget _buildResetDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.white,
      title: const Text(
        'Confirm Reset',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: const Text(
        'Are you sure you want to reset the count?',
        style: TextStyle(color: Colors.black87),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('Reset', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSaveDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.white,
      title: const Text(
        'Confirm Save',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: const Text(
        'Do you want to save the current count?',
        style: TextStyle(color: Colors.black87),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _loadSavedHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasbeehHistory = prefs.getStringList('tasbeehHistory')?.map((e) => int.parse(e)).toList() ?? [];
    });
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          history: _tasbeehHistory,
          onDelete: (index) {
            _deleteCount(index); // Deletes the selected history item
          },
        ),
      ),
    );
  }

  void _deleteCount(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (index >= 0 && index < _tasbeehHistory.length) {
        _tasbeehHistory.removeAt(index);
      }
    });
    await prefs.setStringList(
      'tasbeehHistory',
      _tasbeehHistory.map((e) => e.toString()).toList(),
    );
  }

  Widget _buildTasbeehCard() {
    return ScaleTransition(
      scale: _bounceAnimation!,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tasbeeh Count',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ScaleTransition(
                scale: CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
                child: Text(
                  '$_tasbeehCount',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 90,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Tasbeeh'),
        centerTitle: true,
        elevation: 4.0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _navigateToHistory,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image with Blur
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/beads.png'),
                fit: BoxFit.contain,
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          // Foreground Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTasbeehCard(),
                const SizedBox(height: 30),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: _incrementCount,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(60),
                      backgroundColor: theme.colorScheme.secondary,
                      elevation: 5,
                    ),
                    child: const Icon(Icons.touch_app, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _resetCount,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _saveCount,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  final List<int> history;
  final Function(int) onDelete;

  const HistoryScreen({
    Key? key,
    required this.history,
    required this.onDelete,
  }) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<int> _historyList;

  @override
  void initState() {
    super.initState();
    _historyList = List.from(widget.history); // Clone the history list
  }

  void _removeItem(int index) {
    if (index >= 0 && index < _historyList.length) {  // Safeguard against invalid index access
      final removedItem = _historyList[index];  // Define removedItem here
      setState(() {
        _historyList.removeAt(index);
      });
      widget.onDelete(index);

      if (_listKey.currentState != null) {
        _listKey.currentState!.removeItem(
          index,
              (context, animation) => _buildListItem(removedItem, index, animation),
          duration: const Duration(milliseconds: 400),
        );
      }

      // Show SnackBar with Undo option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted item #${index + 1}', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.teal,
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _historyList.insert(index, removedItem); // Use removedItem here
              });
            },
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildListItem(int item, int index, Animation<double> animation) {
    if (index < 0 || index >= _historyList.length) return SizedBox.shrink(); // Safeguard to prevent invalid index access

    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 0.0,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 6,
        shadowColor: Colors.black38,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.teal,
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            'Count: $item',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: () => _removeItem(index),
          ),
        ),
      ),
    );
  }

  // Function to clear all history
  void _clearHistory() {
    setState(() {
      _historyList.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('History cleared!', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearHistory,
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image with Blur and Overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/beads.png'),
                fit: BoxFit.contain,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),
          // Foreground Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: _historyList.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.history, size: 100, color: Colors.teal),
                        SizedBox(height: 20),
                        Text(
                          'No history available',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  )
                      : AnimatedList(
                    key: _listKey,
                    initialItemCount: _historyList.length,
                    itemBuilder: (context, index, animation) {
                      return _buildListItem(_historyList[index], index, animation);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
