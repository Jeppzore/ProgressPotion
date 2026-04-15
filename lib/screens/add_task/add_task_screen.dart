import 'package:flutter/material.dart';
import 'package:progress_potion/controllers/task_controller.dart';
import 'package:progress_potion/models/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, required this.taskController});

  final TaskController taskController;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskCategory _selectedCategory = TaskCategory.values.first;
  bool _isCreatingTask = false;
  bool _isSavingNewTask = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<TaskCatalogItem> _catalogItemsFor(TaskCategory category) {
    final items = widget.taskController.getCatalogByCategory(category).toList();
    items.sort(_compareCatalogItems);
    return items;
  }

  int _compareCatalogItems(TaskCatalogItem left, TaskCatalogItem right) {
    if (left.isFavorite != right.isFavorite) {
      return left.isFavorite ? -1 : 1;
    }

    if (left.isDefault != right.isDefault) {
      return left.isDefault ? 1 : -1;
    }

    final titleComparison = left.title.compareTo(right.title);
    if (titleComparison != 0) {
      return titleComparison;
    }

    return left.id.compareTo(right.id);
  }

  Future<void> _activateCatalogItem(TaskCatalogItem item) async {
    await widget.taskController.activateCatalogItem(item.id);
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _toggleFavorite(TaskCatalogItem item) async {
    await widget.taskController.toggleFavorite(item.id);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteCatalogItem(TaskCatalogItem item) async {
    await widget.taskController.deleteUserCatalogItem(item.id);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _createCatalogItem() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _isSavingNewTask = true;
    });

    try {
      await widget.taskController.createCatalogItem(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isCreatingTask = false;
        _titleController.clear();
        _descriptionController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to ${_selectedCategory.displayName}.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this task. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingNewTask = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: widget.taskController,
      builder: (context, _) {
        final categoryItems = _catalogItemsFor(_selectedCategory);
        final favoriteCount = categoryItems
            .where((item) => item.isFavorite)
            .length;
        final defaultCount = categoryItems
            .where((item) => item.isDefault)
            .length;

        return Scaffold(
          appBar: AppBar(title: const Text('Task library')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose a category first',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Browse the task library, keep favorites at the top, and add one to your active list when you are ready.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final category in TaskCategory.values)
                            ChoiceChip(
                              label: Text(category.displayName),
                              selected: _selectedCategory == category,
                              onSelected: _isSavingNewTask
                                  ? null
                                  : (isSelected) {
                                      if (!isSelected) {
                                        return;
                                      }

                                      setState(() {
                                        _selectedCategory = category;
                                        _isCreatingTask = false;
                                      });
                                    },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _LibrarySectionHeader(
                title: _selectedCategory.displayName,
                subtitle: categoryItems.isEmpty
                    ? 'No saved tasks yet. Create one or add a starter suggestion.'
                    : '$favoriteCount favorite${favoriteCount == 1 ? '' : 's'} • $defaultCount starter${defaultCount == 1 ? '' : 's'}',
              ),
              const SizedBox(height: 12),
              if (categoryItems.isEmpty)
                _EmptyLibraryCard(
                  onCreatePressed: () {
                    setState(() {
                      _isCreatingTask = true;
                    });
                  },
                )
              else
                for (final item in categoryItems) ...[
                  _LibraryTaskCard(
                    title: item.title,
                    description: item.description,
                    category: item.category,
                    isFavorite: item.isFavorite,
                    isDefault: item.isDefault,
                    onAdd: _isSavingNewTask
                        ? null
                        : () => _activateCatalogItem(item),
                    onFavoriteToggle: _isSavingNewTask
                        ? null
                        : () => _toggleFavorite(item),
                    onDelete: item.isDefault || _isSavingNewTask
                        ? null
                        : () => _deleteCatalogItem(item),
                  ),
                  const SizedBox(height: 12),
                ],
              if (_isCreatingTask) ...[
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create a new task',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'This saves into ${_selectedCategory.displayName} without activating it.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _titleController,
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Task title',
                              hintText: 'Ship the onboarding copy',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Task title is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              hintText: 'Add a quick note for future you.',
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              TextButton(
                                onPressed: _isSavingNewTask
                                    ? null
                                    : () {
                                        setState(() {
                                          _isCreatingTask = false;
                                        });
                                      },
                                child: const Text('Cancel'),
                              ),
                              const Spacer(),
                              FilledButton.icon(
                                onPressed: _isSavingNewTask
                                    ? null
                                    : _createCatalogItem,
                                icon: _isSavingNewTask
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.auto_awesome),
                                label: Text(
                                  _isSavingNewTask
                                      ? 'Saving...'
                                      : 'Save to library',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _isSavingNewTask
                        ? null
                        : () {
                            setState(() {
                              _isCreatingTask = true;
                            });
                          },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Create new task'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LibrarySectionHeader extends StatelessWidget {
  const _LibrarySectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _EmptyLibraryCard extends StatelessWidget {
  const _EmptyLibraryCard({required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No tasks here yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create the first task in this category or add a starter task to Active.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreatePressed,
              icon: const Icon(Icons.add),
              label: const Text('Create new task'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryTaskCard extends StatelessWidget {
  const _LibraryTaskCard({
    required this.title,
    required this.description,
    required this.category,
    required this.isFavorite,
    required this.isDefault,
    required this.onAdd,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  final String title;
  final String description;
  final TaskCategory category;
  final bool isFavorite;
  final bool isDefault;
  final VoidCallback? onAdd;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _LibraryTag(
                            label: category.displayName,
                            color: theme.colorScheme.surfaceContainerHighest,
                            textColor: theme.colorScheme.onSurfaceVariant,
                          ),
                          _LibraryTag(
                            label: isDefault ? 'Starter' : 'Custom',
                            color: isDefault
                                ? theme.colorScheme.tertiaryContainer
                                : theme.colorScheme.secondaryContainer,
                            textColor: theme.colorScheme.onSurfaceVariant,
                          ),
                          if (isFavorite)
                            _LibraryTag(
                              label: 'Favorite',
                              color: theme.colorScheme.primaryContainer,
                              textColor: theme.colorScheme.onSurfaceVariant,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: isFavorite
                      ? 'Remove from favorites'
                      : 'Mark as favorite',
                  child: IconButton.filledTonal(
                    onPressed: onFavoriteToggle,
                    icon: Icon(
                      isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                    ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete'),
                  ),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: onAdd,
                  child: const Text('Add to active'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryTag extends StatelessWidget {
  const _LibraryTag({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
