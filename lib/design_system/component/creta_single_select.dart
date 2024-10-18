import 'package:creta_common/common/creta_color.dart';
import 'package:creta_common/common/creta_font.dart';
import 'package:flutter/material.dart';

import '../../lang/creta_device_lang.dart';

class CretaSingleSelect extends StatefulWidget {
  final Widget title;
  final double listHeight;
  final double textWidth;
  final List<String> items;
  final String initValue;
  final void Function(String?) onSelect;

  const CretaSingleSelect({
    super.key,
    required this.title,
    required this.initValue,
    required this.items,
    required this.onSelect,
    this.listHeight = 80,
    this.textWidth = 360,
  });

  @override
  CretaSingleSelectState createState() => CretaSingleSelectState();
}

class CretaSingleSelectState extends State<CretaSingleSelect> {
  String? _selectedItem;
  bool _showTeams = false;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showTeams = !_showTeams;
                    });
                    widget.onSelect(_selectedItem);
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    width: widget.textWidth,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    color: CretaColor.text[200],
                    child: Text(
                      (_selectedItem == null || _selectedItem!.isEmpty)
                          ? _showTeams
                              ? CretaDeviceLang['chooseOneOfTheTeamsBelow'] ??
                                  ' Choose one of the teams below'
                              : CretaDeviceLang['clickToSelectToTeam'] ?? ' click to select to team'
                          : _selectedItem!,
                      style: const TextStyle(fontSize: 16),
                    ),
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
          _showTeams
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        //color: CretaColor.text[200],
                        height: widget.listHeight,
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 4.0, // Horizontal spacing between children
                            runSpacing: 4.0, // Vertical spacing between lines
                            children: widget.items.map((item) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedItem = item;
                                    _showTeams = false;
                                  });
                                  widget.onSelect(_selectedItem);
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 2.0), // Reduce vertical margin
                                  elevation: 2.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0), // Reduce padding
                                    child: Text(
                                      item,
                                      style: CretaFont.buttonLarge,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _showTeams = false;
                        });
                      },
                    ),
                  ],
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }
}
