import 'package:flutter/material.dart';

import '../../core/database/database_migration_test.dart';

class MigrationTestPage extends StatefulWidget {
  const MigrationTestPage({
    super.key,
  });

  @override
  State<MigrationTestPage> createState() =>
      _MigrationTestPageState();
}

class _MigrationTestPageState
    extends State<MigrationTestPage> {
  bool _isRunning = false;

  MigrationTestResult? _result;

  Future<void> _runTest() async {
    setState(() {
      _isRunning = true;
      _result = null;
    });

    final result =
        await DatabaseMigrationTest.run();

    if (!mounted) {
      return;
    }

    setState(() {
      _isRunning = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Database Migration Test',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.storage,
                ),
                title: const Text(
                  'Current Database Version',
                ),
                subtitle: const Text(
                  'sqlite_part_2.db',
                ),
                trailing: const Text(
                  'v3',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    _isRunning ? null : _runTest,
                icon: _isRunning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.play_arrow,
                      ),
                label: Text(
                  _isRunning
                      ? 'Running Migration Test...'
                      : 'Run Migration Test',
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_result != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _result!.success
                                  ? Icons
                                      .check_circle
                                  : Icons.error,
                              size: 28,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              _result!.success
                                  ? 'Migration Test Passed'
                                  : 'Migration Test Failed',
                              style:
                                  const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const Divider(
                          height: 30,
                        ),

                        Expanded(
                          child: ListView.builder(
                            itemCount:
                                _result!.messages.length,
                            itemBuilder:
                                (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets
                                        .only(
                                  bottom: 10,
                                ),
                                child: Text(
                                  _result!
                                      .messages[index],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text(
                    'Run the migration test to verify '
                    'v1 → v2 → v3.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}