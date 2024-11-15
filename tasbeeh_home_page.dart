import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_screen.dart';


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
      backgroundColor: Colors.transparent, // Make dialog transparent for gradient effect
      contentPadding: EdgeInsets.zero, // Remove default padding
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueAccent.withOpacity(0.20)], // White to light red gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding for dialog content
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Confirm Reset',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to reset the count?',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Reset', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.transparent, // Set to transparent for gradient effect
      contentPadding: EdgeInsets.zero, // Remove default padding
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueAccent.withOpacity(0.20)], // Two-color gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding within dialog
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Confirm Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Do you want to save the current count?',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
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
              ),
            ],
          ),
        ),
      ),
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueAccent], // Replace with your desired colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.1),
          color: Colors.transparent, // Make Card's color transparent
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
                    color: Colors.white,
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
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Tasbeeh'),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4.0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.blueAccent],
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
                image: AssetImage('assets/images/tasbih (2).png'),
                fit: BoxFit.contain,
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.9), // First color with opacity
                      Colors.blueAccent.withOpacity(0.5),   // Second color with opacity
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.blueAccent], // Change to your desired colors
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: ElevatedButton(
                  onPressed: _incrementCount,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(60),
                    elevation: 5,
                    backgroundColor: Colors.transparent, // Set background to transparent
                  ),
                  child: const Icon(Icons.touch_app, size: 80, color: Colors.white),
                ),
              ),
            ),
              const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.blueAccent], // Specify your two colors here
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15), // Match the button's border radius
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _resetCount,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                          backgroundColor: Colors.transparent, // Set to transparent to see the gradient
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.blueAccent], // Specify your two colors here
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15), // Match the button's border radius
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _saveCount,
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                          backgroundColor: Colors.transparent, // Set to transparent to see the gradient
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
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
