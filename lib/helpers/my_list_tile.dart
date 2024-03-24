import 'package:flutter/material.dart';

class MyListTile extends StatefulWidget {
  final String id;
  final String subtitle;
  final String imageUrl;
  final bool selected;
  final ValueChanged<bool>? onSelectedChanged;

  const MyListTile({
    Key? key,
    required this.id,
    required this.subtitle,
    required this.imageUrl,
    this.selected = false,
    this.onSelectedChanged,
  }) : super(key: key);

  factory MyListTile.fromJson(Map<String, dynamic> json) {
    return MyListTile(
      key: Key(json['id'].toString()), // กำหนด key ด้วย id จาก JSON
      id: json['id'],
      subtitle: json['subtitle'],
      imageUrl: '${json['image']}',
      selected: json['selected'] ?? false,
    );
  }

  @override
  _MyListTileState createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          widget.onSelectedChanged?.call(!widget.selected);
        });
      },
      child: Container(
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: widget.selected
                ? colorScheme.primary.withOpacity(0.8)
                : Colors.transparent,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Container(
                    width: 100.0,
                    height: 80.0,
                    child: Image.network(widget.imageUrl),
                  ),
                ),
                SizedBox(width: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.id, style: textTheme.bodyText1),
                    SizedBox(height: 4.0),
                    Text(widget.subtitle),
                  ],
                ),
              ],
            ),
            if (widget.selected)
              Positioned(
                top: 8.0,
                right: 8.0,
                child: Container(
                  padding: EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 16.0),
                ),
              )
          ],
        ),
      ),
    );
  }
}
