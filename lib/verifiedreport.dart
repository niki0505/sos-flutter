import 'package:flutter/material.dart';
import 'package:frontend/adminhome.dart';
import 'package:frontend/services/firestore.dart';

class VerifiedReportPage extends StatefulWidget {
  final String sosID;

  const VerifiedReportPage({super.key, required this.sosID});

  @override
  State<VerifiedReportPage> createState() => _VerifiedReportPageState();
}

class _VerifiedReportPageState extends State<VerifiedReportPage> {
  final FirestoreService fireStoreService = FirestoreService();
  final TextEditingController _actionController = TextEditingController();
  final int _maxLength = 1000;

  @override
  Widget build(BuildContext context) {
    const redColor = Color.fromRGBO(250, 82, 70, 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.asset("assets/back_red.png", height: 35),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "VERIFIED REPORT",
                        style: TextStyle(
                          fontFamily: "REM",
                          color: redColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Please fill out the required information to submit an update.",
                        style: TextStyle(
                          fontFamily: "Quicksand",
                          color: Colors.black54,
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Actions Taken on Scene*",
                        style: TextStyle(
                          fontFamily: "REM",
                          color: redColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        height: 150,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _actionController,
                          maxLength: _maxLength,
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(
                            fontFamily: "REM",
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                "Describe any actions you or your team took upon arrival.",
                            hintStyle: TextStyle(
                              fontFamily: "Quicksand",
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            counterText: "",
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "${_actionController.text.length}/$_maxLength",
                          style: const TextStyle(
                            fontFamily: "Quicksand",
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_actionController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please fill out the required field.",
                                  ),
                                ),
                              );
                            } else {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Confirm Verify"),
                                  content: const Text(
                                    "Are you sure you want to verify this report?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text("Confirm"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await fireStoreService.verifySOS(
                                  widget.sosID,
                                  _actionController.text,
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminHomeScreen(),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: redColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            shadowColor: Colors.black.withOpacity(0.4),
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(
                              fontFamily: "REM",
                              fontWeight: FontWeight.bold,
                              fontSize: 21,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 10,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
