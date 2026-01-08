import 'package:flutter/material.dart';
import '../models/daily_checkin.dart';
import '../services/checkin_service.dart';

class CheckinScreen extends StatefulWidget {
  final DailyCheckin? existingCheckin;
  const CheckinScreen({super.key, this.existingCheckin});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  late int _mood;
  late String _energy;
  late bool _sleep;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mood = widget.existingCheckin?.mood ?? 3;
    _energy = widget.existingCheckin?.energy ?? 'mid';
    _sleep = widget.existingCheckin?.sleep ?? true;
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final checkin = DailyCheckin(mood: _mood, energy: _energy, sleep: _sleep);
    final result = await CheckinService.submitCheckin(checkin);
    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Check-in saved!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _error = result['error'];
      });
    }
  }

  String _getMoodEmoji(int m) => ['', '😢', '😕', '😐', '🙂', '😊'][m];
  String _getMoodLabel(int m) =>
      ['', 'Very Low', 'Low', 'Okay', 'Good', 'Great'][m];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.existingCheckin != null
              ? 'Update Check-in'
              : 'Daily Check-in')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mood
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('How are you feeling?',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        Text(_getMoodEmoji(_mood),
                            style: const TextStyle(fontSize: 64)),
                        Text(_getMoodLabel(_mood),
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: theme.colorScheme.primary)),
                        Slider(
                            value: _mood.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            onChanged: (v) =>
                                setState(() => _mood = v.round())),
                      ],
                    ))),
            const SizedBox(height: 16),
            // Energy
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Energy level?',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        Row(children: [
                          _buildEnergyBtn(
                              'low', 'Low', Icons.battery_1_bar, Colors.red),
                          const SizedBox(width: 8),
                          _buildEnergyBtn(
                              'mid', 'Mid', Icons.battery_4_bar, Colors.orange),
                          const SizedBox(width: 8),
                          _buildEnergyBtn(
                              'high', 'High', Icons.battery_full, Colors.green),
                        ]),
                      ],
                    ))),
            const SizedBox(height: 16),
            // Sleep
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Slept well?',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        Row(children: [
                          _buildSleepBtn(
                              true, 'Yes', Icons.bedtime, Colors.green),
                          const SizedBox(width: 12),
                          _buildSleepBtn(
                              false, 'No', Icons.bedtime_off, Colors.red),
                        ]),
                      ],
                    ))),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_error!,
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyBtn(String val, String label, IconData icon, Color color) {
    final sel = _energy == val;
    return Expanded(
        child: GestureDetector(
      onTap: () => setState(() => _energy = val),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: sel ? color.withOpacity(0.15) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: sel ? color : Colors.transparent, width: 2)),
        child: Column(children: [
          Icon(icon, color: sel ? color : Colors.grey),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: sel ? color : Colors.grey,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal))
        ]),
      ),
    ));
  }

  Widget _buildSleepBtn(bool val, String label, IconData icon, Color color) {
    final sel = _sleep == val;
    return Expanded(
        child: GestureDetector(
      onTap: () => setState(() => _sleep = val),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: sel ? color.withOpacity(0.15) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: sel ? color : Colors.transparent, width: 2)),
        child: Column(children: [
          Icon(icon, color: sel ? color : Colors.grey, size: 32),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: sel ? color : Colors.grey,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal))
        ]),
      ),
    ));
  }
}
