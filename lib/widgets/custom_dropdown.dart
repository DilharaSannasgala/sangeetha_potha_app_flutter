import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_components.dart';

class CustomDropdown extends StatefulWidget {
  final String? selectedValue;
  final List<String> items;
  final Function(String?)? onChanged;
  final double width;
  final double height;

  const CustomDropdown({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.width = 300, // Default width
    this.height = 50, // Default height
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> with TickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  String? _currentValue;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.selectedValue; // Set initial value
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: widget.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, widget.height + 5),
          child: Material(
            color: Colors.transparent,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: SizeTransition(
                    sizeFactor: CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeInOut,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.items
                          .map((item) => InkWell(
                                onTap: () {
                                  setState(() {
                                    _currentValue = item;
                                    _isDropdownOpen = false;
                                    if (widget.onChanged != null) {
                                      widget.onChanged!(item);
                                    }
                                  });
                                  _overlayEntry?.remove();
                                  _controller.reverse(); // Reverse animation
                                },
                                child: Container(
                                  width: widget.width,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      // Show icon only when the dropdown is open and it's a selected item
                                      if (_currentValue == item && _isDropdownOpen)
                                        SvgPicture.asset(
                                          AppComponents.tickIcon,
                                          height: 16,
                                          width: 16,
                                        ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _overlayEntry?.remove();
      _controller.reverse();
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      _controller.forward();
    }
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white, // Border color
              width: 1, // Border width
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x60000000),
                spreadRadius: 0,
                offset: Offset(0, 20),
                blurRadius: 40,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentValue ?? 'Select', // Display selected value or default
                style: const TextStyle(color: Colors.white),
              ),
              AnimatedRotation(
                turns: _isDropdownOpen ? 0.5 : 0.0, // Rotate icon when opened
                duration: const Duration(milliseconds: 200),
                child: SvgPicture.asset(
                  AppComponents.dropDownIcon, // Custom SVG dropdown icon
                  height: 16,
                  width: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the animation controller
    _overlayEntry?.remove();
    super.dispose();
  }
}
