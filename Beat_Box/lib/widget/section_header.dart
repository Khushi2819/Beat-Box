import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    Key? key,
    required this.title,
    this.action = 'View More',
    required this.onViewMoreTap, // Add this line
  }) : super(key: key);

  final String title;
  final String action;
  final VoidCallback onViewMoreTap; // Add this line

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onViewMoreTap, // Handle the tap event
          child: Text(
            action,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
