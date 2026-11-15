import 'package:flutter/material.dart';
import '../../services/conversational_memory_service.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final _memory = ConversationalMemoryService.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMemory();
  }

  Future<void> _loadMemory() async {
    await _memory.init();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _deleteFact(String id) async {
    await _memory.deleteFact(id);
    if (mounted) setState(() {});
  }

  Future<void> _clearMemory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear saved memories?'),
        content: const Text(
          'This removes saved memory facts. Your conversation history is not cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear memories'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _memory.clearAllFacts();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final facts = _memory.facts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
        actions: [
          if (facts.isNotEmpty)
            IconButton(
              tooltip: 'Clear saved memories',
              onPressed: _clearMemory,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : facts.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.psychology_outlined, size: 52),
                        SizedBox(height: 12),
                        Text(
                          'No saved memories yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'When JARVIS saves something important, it will appear here.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: facts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final fact = facts[index];
                    return Card(
                      child: ListTile(
                        title: Text(fact.fact),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${fact.category} • ${fact.createdAt.toLocal()}',
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Delete this memory',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteFact(fact.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
