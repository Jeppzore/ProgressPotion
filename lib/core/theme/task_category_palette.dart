import 'package:flutter/material.dart';
import 'package:progress_potion/models/task.dart';

Color taskCategoryColor(TaskCategory category) {
  return switch (category) {
    TaskCategory.fitness => const Color(0xFFD05A4E),
    TaskCategory.home => const Color(0xFFC88944),
    TaskCategory.study => const Color(0xFF4878D9),
    TaskCategory.work => const Color(0xFF4168C8),
    TaskCategory.hobby => const Color(0xFF4F9770),
  };
}
