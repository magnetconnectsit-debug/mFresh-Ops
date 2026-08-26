import 'package:core/widgets/app_common_app_bar.dart';
import 'package:flutter/material.dart';

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
class AppCommonDropdownPage<T> extends StatefulWidget {
  final String title;
  final List<DropdownOption<T>> options;
  final bool isMultiSelect;
  final List<DropdownOption<T>>? initialSelection;

  const AppCommonDropdownPage({
    required this.title,
    required this.options,
    this.isMultiSelect = false,
    this.initialSelection,
    super.key,
  });

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

  @override
  State<AppCommonDropdownPage<T>> createState() => _AppCommonDropdownPageState<T>();
}

class _AppCommonDropdownPageState<T> extends State<AppCommonDropdownPage<T>> {
  late List<DropdownOption<T>> _filteredOptions;
  late List<DropdownOption<T>> _selectedOptions;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _selectedOptions = List.from(widget.initialSelection ?? []);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = widget.options;
      } else {
        _filteredOptions = widget.options.where((option) {
          return option.label.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _onToggle(DropdownOption<T> option) {
    setState(() {
      if (widget.isMultiSelect) {
        if (_selectedOptions.any((element) => element.value == option.value)) {
          _selectedOptions.removeWhere((element) => element.value == option.value);
        } else {
          _selectedOptions.add(option);
        }
      } else {
        _selectedOptions = [option];
        Navigator.of(context).pop(_selectedOptions);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppCommonAppBar(
        title: Text(widget.title),
        actions: [
          if (widget.isMultiSelect)
            TextButton(
              onPressed: () => Navigator.of(context).pop(_selectedOptions),
              child: const Text('Done'),
            ),
        ],
      ),
      body: Column(
        children: [
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
          // region Select All
          if (widget.isMultiSelect)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Select All', style: TextStyle(fontWeight: FontWeight.bold)),
                value: _selectedOptions.length == widget.options.length,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedOptions = List.from(widget.options);
                    } else {
                      _selectedOptions.clear();
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
          // endregion

          Expanded(
            child: ListView.builder(
              itemCount: _filteredOptions.length,
              itemBuilder: (context, index) {
                final option = _filteredOptions[index];
                final isSelected = _selectedOptions.any((element) => element.value == option.value);

                if (widget.isMultiSelect) {
                  return CheckboxListTile(
                    title: Text(option.label),
                    value: isSelected,
                    onChanged: (bool? value) => _onToggle(option),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Theme.of(context).primaryColor,
                  );
                } else {
                  return ListTile(
                    title: Text(option.label),
                    trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
                    onTap: () => _onToggle(option),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
// endregion










