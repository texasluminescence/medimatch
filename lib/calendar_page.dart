// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'colors.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int selectedDay = DateTime.now().day;

  List<Map<String, String>> activeMedications = [
    {"name": "Omega-3 Fish Oil", "dose": "1 mL", "type": "Gel Capsule"},
    {"name": "Vitamin D", "dose": "1 capsule", "type": "Capsule"},
  ];

  List<Map<String, String>> loggedMedications = [];

  void _openMedicationDetails() {
    // Create a temporary state to track selections
    final tempTakenState = <Map<String, String>, bool>{};
    for (var med in [...activeMedications, ...loggedMedications]) {
      tempTakenState[med] = loggedMedications.contains(med);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          builder: (context, scrollController) {
            final combined = [...activeMedications, ...loggedMedications];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text("Cancel",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text("10:00 AM Medication",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  for (final med in combined)
                    _buildLogItem(med, tempTakenState[med] ?? false, () {
                      setModalState(() {
                        tempTakenState[med] = !(tempTakenState[med] ?? false);
                      });
                    }),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          activeMedications.clear();
                          loggedMedications.clear();
                          tempTakenState.forEach((med, taken) {
                            if (taken) {
                              loggedMedications.add(med);
                            } else {
                              activeMedications.add(med);
                            }
                          });
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F0F0),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Done",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF999999))),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogItem(
      Map<String, String> med, bool isTaken, VoidCallback onToggle) {
    return Container(
      key: ValueKey(med['name']),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 26,
                child: Icon(Icons.medication, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med['name']!,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(med['type']!,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                        "${med['dose']} at ${DateFormat('h:mm a').format(DateTime.now())}",
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text("Skipped",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.indigo)),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: isTaken ? Colors.blue : const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isTaken)
                          const Icon(Icons.check,
                              color: Colors.white, size: 16),
                        if (isTaken) const SizedBox(width: 4),
                        Text(
                          "Taken",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isTaken ? Colors.white : Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: AppColors.mintColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "MEDIMATCH",
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeeklyCalendar(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Log",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          _buildMedicationLog(),
          _buildLoggedSection(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Your Medications",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          _buildMedicationList(),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    final today = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (index) {
          final date = today.add(Duration(days: index - today.weekday + 1));
          final isSelected = selectedDay == date.day;
          return GestureDetector(
            onTap: () => setState(() => selectedDay = date.day),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mintColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                children: [
                  Text("${date.day}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : Colors.grey[600])),
                  Text(
                      [
                        "Mon",
                        "Tue",
                        "Wed",
                        "Thu",
                        "Fri",
                        "Sat",
                        "Sun"
                      ][date.weekday - 1],
                      style: TextStyle(
                          color: isSelected ? Colors.black : Colors.grey[600])),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMedicationLog() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F0FF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("10:00 AM",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: _openMedicationDetails),
              ],
            ),
            const SizedBox(height: 8),
            if (activeMedications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "All Scheduled Medications Logged Today",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic),
                ),
              )
            else
              for (final med in activeMedications)
                _medicationItem(med["name"]!, med["dose"]!, med["type"]!),
          ],
        ),
      ),
    );
  }

  Widget _medicationItem(String name, String dose, String type) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(name),
        subtitle: Text("$dose • $type"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(onPressed: () {}, child: const Text("Skipped")),
            TextButton(onPressed: () {}, child: const Text("Taken")),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedSection() {
    if (loggedMedications.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Logged",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: _openMedicationDetails,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('h:mm a').format(DateTime.now()),
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text("1h ago", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            for (final med in loggedMedications)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(Icons.check,
                          size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(med["name"]!),
                  ],
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationList() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _pillCard("Omega-3 Fish Oil", "900 mg, 1 pill", Colors.blue[50]!),
          _pillCard("Vitamin D", "125 mcg, 1 pill", Colors.orange[50]!),
        ],
      ),
    );
  }

  Widget _pillCard(String name, String dosage, Color background) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.medication, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(dosage),
            ],
          ),
        ],
      ),
    );
  }
}

class FullMedicationLog extends StatelessWidget {
  final List<Map<String, String>> medications;
  final List<Map<String, String>> logged;
  final void Function(Map<String, String>) onToggleTaken;

  const FullMedicationLog(
      {super.key,
      required this.medications,
      required this.logged,
      required this.onToggleTaken});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d').format(now);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      builder: (context, scrollController) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final combined = [...medications, ...logged];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text("Cancel",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(formattedDate,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text("10:00 AM Medication",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  for (final med in combined)
                    _logItem(
                      name: med["name"]!,
                      dose:
                          "${med["dose"]} at ${DateFormat('h:mm a').format(DateTime.now())}",
                      type: med["type"]!,
                      taken: logged.contains(med),
                      onToggle: () => onToggleTaken(med),
                    ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F0F0),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Done",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF999999))),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _logItem({
    required String name,
    required String dose,
    required String type,
    required bool taken,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: taken ? Colors.blue : Colors.grey,
                radius: 26,
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(type,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(dose,
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text("Skipped",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.indigo)),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: taken ? Colors.blue : const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (taken)
                          const Icon(Icons.check,
                              color: Colors.white, size: 16),
                        if (taken) const SizedBox(width: 4),
                        Text(
                          "Taken",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: taken ? Colors.white : Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
