import 'package:futblha/presentation/widgets/scaffold_pading.dart';
import 'package:flutter/material.dart';

import 'custom_empty_widget.dart';
import 'custom_text.dart';

void showDropdownOptions<T>(
    BuildContext context, TextEditingController controller, String Function(T?) displayTextFunction,
    {Function(T)? onChange, required List<T> items}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      if (items.isEmpty) {
        return const Center(child: EmptyWidget());
      }
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];
          final text = displayTextFunction.call(item);
          return ListTile(
            title: CustomText(
              text,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            contentPadding: symmetricPadding(0, 20),
            onTap: () {
              controller.text = text;
              if (onChange != null) onChange(item);
              Navigator.pop(context);
            },
          );
        },
      );
    },
  );
}
