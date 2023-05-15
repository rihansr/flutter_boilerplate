import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SwitchWidget extends StatefulWidget {
  const SwitchWidget({
    Key? key,
    this.onChanged,
    this.value,
  })  : maintainState = false,
        super(key: key);

  const SwitchWidget.maintainState({
    Key? key,
    this.onChanged,
    this.value,
  })  : maintainState = true,
        super(key: key);

  final Function(bool)? onChanged;
  final bool? value;
  final bool maintainState;

  @override
  State<SwitchWidget> createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  late bool switchState;

  @override
  void initState() {
    switchState = widget.value ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Transform.scale(
        alignment: Alignment.centerRight,
        scale: 0.65,
        child: CupertinoSwitch(
          activeColor: Theme.of(context).colorScheme.onPrimary,
          value: widget.maintainState ? switchState : (widget.value ?? false),
          onChanged: (state) => {
            widget.maintainState
                ? setState(() => switchState = state)
                : switchState = state,
            widget.onChanged?.call(state),
          },
        ),
      );
}
