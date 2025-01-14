import 'package:fluent_ui/fluent_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StarsRateWidget extends StatefulWidget {
  StarsRateWidget(
      {Key? key,
      required this.defaultStars,
      this.onStarChanged,
      this.readOnly = false,
      this.color})
      : super(key: key);

  final int defaultStars;
  final Function(int)? onStarChanged;
  final bool readOnly;
  Color? color;

  @override
  State<StarsRateWidget> createState() => _StarsRateWidgetState();
}

class _StarsRateWidgetState extends State<StarsRateWidget> {
  int stars = 0;

  @override
  void initState() {
    stars = widget.defaultStars;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      for (int i = 0; i < 5; i++)
        !widget.readOnly
            ? IconButton(
                iconButtonMode: IconButtonMode.large,
                icon: Icon(
                  size: 24,
                  i < stars
                      ? FontAwesomeIcons.solidStar
                      : FontAwesomeIcons.star,
                  color: i < stars ? Colors.yellow : Colors.white,
                ),
                onPressed: () {
                  if (stars == i + 1) {
                    setState(() {
                      stars = 0;
                    });
                    if (widget.onStarChanged != null) {
                      widget.onStarChanged!(0);
                    }
                  } else {
                    setState(() {
                      stars = i + 1;
                    });
                    if (widget.onStarChanged != null) {
                      widget.onStarChanged!(stars);
                    }
                  }
                })
            : Row(children: [
                Icon(
                  size: 18,
                  i < stars
                      ? FontAwesomeIcons.solidStar
                      : FontAwesomeIcons.star,
                  color: widget.color != null
                      ? widget.color
                      : i < stars
                          ? Colors.yellow
                          : Colors.white,
                ),
                SizedBox(
                  width: 2,
                )
              ])
    ]);
  }
}
