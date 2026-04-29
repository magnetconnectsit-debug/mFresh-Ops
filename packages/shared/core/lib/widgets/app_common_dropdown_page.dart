import 'package:core/widgets/app_common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// region DropdownOption
class DropdownOption<T> {
  const DropdownOption({required this.value, required this.label});

  final T value;
  final String label;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownOption<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
// endregion

// region AppCommonDropdownPage
class AppCommonDropdownPage<T> extends StatelessWidget {
  // region Constructor
  AppCommonDropdownPage({
    required this.title,
    required this.options,
    this.isMultiSelect = false,
    List<DropdownOption<T>>? initialSelection,
    super.key,
  }) {
    selectedOptions.value = initialSelection ?? [];
    filteredOptions.value = options;
  }

  /// Helper route method to navigate to this page
  static Future<List<DropdownOption<T>>?> show<T>(
    BuildContext context, {
    required String title,
    required List<DropdownOption<T>> options,
    bool isMultiSelect = false,
    List<DropdownOption<T>>? initialSelection,
  }) {
    return Navigator.of(context).push<List<DropdownOption<T>>>(
      MaterialPageRoute(
        builder: (_) => AppCommonDropdownPage<T>(
          title: title,
          options: options,
          isMultiSelect: isMultiSelect,
          initialSelection: initialSelection,
        ),
      ),
    );
  }

  // endregion

  // region Properties
  final String title;
  final List<DropdownOption<T>> options;
  final bool isMultiSelect;
  // endregion

  // region Reactive State
  final RxList<DropdownOption<T>> filteredOptions = <DropdownOption<T>>[].obs;
  final RxList<DropdownOption<T>> selectedOptions = <DropdownOption<T>>[].obs;
  final _searchController = TextEditingController();
  // endregion

  // region Helpers
  void _filterList(String query) {
    if (query.isEmpty) {
      filteredOptions.value = options;
    } else {
      filteredOptions.value = options.where((option) {
        return option.label.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void _onToggle(BuildContext context, DropdownOption<T> option) {
    if (isMultiSelect) {
      // Multi-select logic
      if (selectedOptions.contains(option)) {
        selectedOptions.remove(option);
      } else {
        selectedOptions.add(option);
      }
    } else {
      // Single-select logic
      selectedOptions.value = [option];
      // For single-select, pop immediately after selection
      Navigator.of(context).pop(selectedOptions.toList());
    }
  }

  // endregion

  // region Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppCommonAppBar(
        title: Text(title),
        // Only show 'Done' button for multi-select
        actions: [
          if (isMultiSelect)
            TextButton(
              onPressed: () => Navigator.of(context).pop(selectedOptions.toList()),
              child: const Text('Done'),
            ),
        ],
      ),
      body: Column(
        children: [
          // region Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterList,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
            ),
          ),
          // endregion

          // region List
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: filteredOptions.length,
                  itemBuilder: (context, index) {
                    final option = filteredOptions[index];
                    final isSelected = selectedOptions.contains(option);

                    return CheckboxListTile(
                      title: Text(option.label),
                      value: isSelected,
                      onChanged: (bool? value) => _onToggle(context, option),
                      // Use Checkbox for multi-select, Radio for single-select
                      controlAffinity: isMultiSelect
                          ? ListTileControlAffinity.leading
                          : ListTileControlAffinity.trailing,
                      secondary: isMultiSelect
                          ? null
                          : (isSelected ? const Icon(Icons.check) : null),
                      activeColor: Theme.of(context).primaryColor,
                    );
                  },
                )),
          ),
          // endregion
        ],
      ),
    );
  }
}

// endregion










