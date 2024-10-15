import 'package:flutter/material.dart';

class CretaSingleSelect extends StatefulWidget {
  final Widget title;
  final double listHeight;
  final List<String> items;
  final String initValue;
  final void Function(String?) onSelect;

  const CretaSingleSelect({
    super.key,
    required this.title,
    required this.initValue,
    required this.items,
    required this.onSelect,
    this.listHeight = 100,
  });

  @override
  CretaSingleSelectState createState() => CretaSingleSelectState();
}

class CretaSingleSelectState extends State<CretaSingleSelect> {
  String? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initValue;
  }

  @override
  void didUpdateWidget(CretaSingleSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initValue != widget.initValue) {
      _selectedItem = widget.initValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          widget.title,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: widget.listHeight,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0, // Horizontal spacing between children
                  runSpacing: 4.0, // Vertical spacing between lines
                  children: widget.items.map((item) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedItem = item;
                        });
                        widget.onSelect(_selectedItem);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 2.0), // Reduce vertical margin
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0), // Reduce padding
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    (_selectedItem == null || _selectedItem!.isEmpty)
                        ? 'click to select to team'
                        : _selectedItem!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _selectedItem = null;
                  });
                  widget.onSelect(_selectedItem);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
