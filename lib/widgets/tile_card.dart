// lib/widgets/tile_card.dart
import 'package:flutter/material.dart';

class GridItem {
  final String title;
  final String assetPath;
  final VoidCallback onTap;
  const GridItem({
    required this.title,
    required this.assetPath,
    required this.onTap,
  });
}

class TileCard extends StatelessWidget {
  final GridItem item;
  const TileCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest.shortestSide;
              final padding = size * 0.08; // 8% padding
              final iconSize = (size * 0.4).clamp(32.0, 80.0); // Smaller icon ratio
              final spacing = (size * 0.06).clamp(4.0, 12.0); // Adaptive spacing
              final fontSize = (size * 0.08).clamp(10.0, 16.0); // Adaptive font size
              
              return Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: iconSize,
                          maxWidth: iconSize,
                        ),
                        child: Image.asset(
                          item.assetPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: spacing),
                    Flexible(
                      flex: 2,
                      child: Text(
                        item.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: fontSize,
                          height: 1.2, // Tighter line height
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
