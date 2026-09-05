import 'package:flutter/material.dart';

import '../../core/database/transaction_failure_test.dart';

class TransactionTestPage extends StatefulWidget {
  const TransactionTestPage({
    super.key,
  });

  @override
  State<TransactionTestPage> createState() =>
      _TransactionTestPageState();
}

class _TransactionTestPageState
    extends State<TransactionTestPage> {
  bool _isRunning = false;

  TransactionTestResult? _result;

  Future<void> _runTest() async {
    setState(() {
      _isRunning = true;
      _result = null;
    });

    final result =
        await TransactionFailureTest.run();

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
          'Transaction Test',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.sync_lock,
                ),
                title: const Text(
                  'Transaction Rollback Test',
                ),
                subtitle: const Text(
                  'Insert user → force failure → verify rollback',
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
                      ? 'Running Test...'
                      : 'Run Rollback Test',
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
                                  ? Icons.check_circle
                                  : Icons.error,
                              size: 28,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              _result!.success
                                  ? 'Test Passed'
                                  : 'Test Failed',
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
                    'Run the test to verify '
                    'transaction rollback.',
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