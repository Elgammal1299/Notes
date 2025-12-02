import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  // App Bar
  String get appTitle => locale.languageCode == 'ar' ? 'ملاحظات رائعة 📒' : 'Awesome Notes📒';
  String get newNote => locale.languageCode == 'ar' ? 'ملاحظة جديدة' : 'New Note';
  String get editNote => locale.languageCode == 'ar' ? 'تعديل الملاحظة' : 'Edit Note';

  // Search
  String get search => locale.languageCode == 'ar' ? 'بحث...' : 'Search...';
  String get noNotesFound => locale.languageCode == 'ar'
      ? 'لا توجد ملاحظات لعبارة البحث هذه!'
      : 'No notes found for your search query!';

  // Note Editor
  String get titleHere => locale.languageCode == 'ar' ? 'العنوان هنا' : 'Title here';
  String get noteHere => locale.languageCode == 'ar' ? 'اكتب ملاحظتك هنا...' : 'Note here...';

  // Metadata
  String get lastModified => locale.languageCode == 'ar' ? 'آخر تعديل' : 'Last Modified';
  String get created => locale.languageCode == 'ar' ? 'تاريخ الإنشاء' : 'Created';
  String get tags => locale.languageCode == 'ar' ? 'الوسوم' : 'Tags';

  // Tags
  String get addTag => locale.languageCode == 'ar' ? 'إضافة وسم' : 'Add tag';
  String get addTagHint => locale.languageCode == 'ar'
      ? 'إضافة وسم (أقل من 16 حرف)'
      : 'Add tag (< 16 characters)';
  String get noTagsAdded => locale.languageCode == 'ar' ? 'لم تضف أي وسوم' : 'No tags added';
  String get tagsTooLong => locale.languageCode == 'ar'
      ? 'الوسوم يجب ألا تزيد عن 16 حرف'
      : 'Tags should not be more than 16 characters';
  String get add => locale.languageCode == 'ar' ? 'إضافة' : 'Add';

  // Dialogs
  String get yes => locale.languageCode == 'ar' ? 'نعم' : 'Yes';
  String get no => locale.languageCode == 'ar' ? 'لا' : 'No';
  String get ok => locale.languageCode == 'ar' ? 'حسناً' : 'OK';
  String get saveNote => locale.languageCode == 'ar'
      ? 'هل تريد حفظ الملاحظة؟'
      : 'Do you want to save the note?';
  String get deleteNote => locale.languageCode == 'ar'
      ? 'هل تريد حذف هذه الملاحظة؟'
      : 'Do you want to delete this note?';

  // Empty State
  String get noNotesYet => locale.languageCode == 'ar'
      ? 'ليس لديك أي ملاحظات بعد!\nابدأ بإنشاء ملاحظة بالضغط على زر + بالأسفل!'
      : 'You have no notes yet!\nStart creating by pressing the + button below!';

  // Order Options
  String get dateModified => locale.languageCode == 'ar' ? 'تاريخ التعديل' : 'Date Modified';
  String get dateCreated => locale.languageCode == 'ar' ? 'تاريخ الإنشاء' : 'Date Created';

  // Language
  String get changeLanguage => locale.languageCode == 'ar' ? 'تغيير اللغة' : 'Change Language';

  // Reminder
  String get setReminder => locale.languageCode == 'ar' ? 'تعيين تذكير' : 'Set Reminder';
  String get removeReminder => locale.languageCode == 'ar' ? 'إزالة التذكير' : 'Remove Reminder';
  String get reminderSet => locale.languageCode == 'ar' ? 'تم تعيين التذكير' : 'Reminder Set';
  String get reminderRemoved => locale.languageCode == 'ar' ? 'تم إزالة التذكير' : 'Reminder Removed';
  String get selectDateTime => locale.languageCode == 'ar' ? 'اختر التاريخ والوقت' : 'Select Date & Time';
  String get cancel => locale.languageCode == 'ar' ? 'إلغاء' : 'Cancel';
  String get set => locale.languageCode == 'ar' ? 'تعيين' : 'Set';
  String get reminder => locale.languageCode == 'ar' ? 'تذكير' : 'Reminder';
  String get noReminderSet => locale.languageCode == 'ar' ? 'لم يتم تعيين تذكير' : 'No reminder set';

  // To-Do List
  String get todos => locale.languageCode == 'ar' ? 'قائمة المهام' : 'To-Do List';
  String get notes => locale.languageCode == 'ar' ? 'الملاحظات' : 'Notes';
  String get all => locale.languageCode == 'ar' ? 'الكل' : 'All';
  String get active => locale.languageCode == 'ar' ? 'نشط' : 'Active';
  String get completed => locale.languageCode == 'ar' ? 'مكتمل' : 'Completed';
  String get overdue => locale.languageCode == 'ar' ? 'متأخر' : 'Overdue';
  String get allCategories => locale.languageCode == 'ar' ? 'كل الفئات' : 'All Categories';
  String get noTodosFound => locale.languageCode == 'ar' ? 'لا توجد مهام!' : 'No to-dos found!';
  String get comingSoon => locale.languageCode == 'ar' ? 'قريباً...' : 'Coming soon...';

  // Categories
  String get personal => locale.languageCode == 'ar' ? 'شخصي' : 'Personal';
  String get work => locale.languageCode == 'ar' ? 'عمل' : 'Work';
  String get shopping => locale.languageCode == 'ar' ? 'تسوق' : 'Shopping';
  String get health => locale.languageCode == 'ar' ? 'صحة' : 'Health';
  String get other => locale.languageCode == 'ar' ? 'أخرى' : 'Other';

  // Date formatting
  String get today => locale.languageCode == 'ar' ? 'اليوم' : 'Today';
  String get tomorrow => locale.languageCode == 'ar' ? 'غداً' : 'Tomorrow';
  String get recurring => locale.languageCode == 'ar' ? 'متكرر' : 'Recurring';

  String formatDate(DateTime date) {
    if (locale.languageCode == 'ar') {
      return '${date.day}/${date.month}/${date.year}';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  // Add/Edit To-Do
  String get newTodo => locale.languageCode == 'ar' ? 'مهمة جديدة' : 'New To-Do';
  String get editTodo => locale.languageCode == 'ar' ? 'تعديل المهمة' : 'Edit To-Do';
  String get todoTitle => locale.languageCode == 'ar' ? 'العنوان' : 'Title';
  String get todoTitleHint => locale.languageCode == 'ar' ? 'أدخل عنوان المهمة...' : 'Enter todo title...';
  String get todoDescription => locale.languageCode == 'ar' ? 'الوصف' : 'Description';
  String get todoDescriptionHint => locale.languageCode == 'ar' ? 'أدخل وصف المهمة (اختياري)...' : 'Enter description (optional)...';
  String get deleteTodo => locale.languageCode == 'ar' ? 'حذف المهمة' : 'Delete To-Do';
  String get deleteTodoConfirm => locale.languageCode == 'ar' ? 'هل تريد حذف هذه المهمة؟' : 'Do you want to delete this to-do?';

  // Priority
  String get priority => locale.languageCode == 'ar' ? 'الأولوية' : 'Priority';
  String get lowPriority => locale.languageCode == 'ar' ? 'منخفضة' : 'Low';
  String get mediumPriority => locale.languageCode == 'ar' ? 'متوسطة' : 'Medium';
  String get highPriority => locale.languageCode == 'ar' ? 'عالية' : 'High';

  // Category
  String get category => locale.languageCode == 'ar' ? 'الفئة' : 'Category';

  // Dates
  String get dueDate => locale.languageCode == 'ar' ? 'تاريخ الاستحقاق' : 'Due Date';
  String get selectDueDate => locale.languageCode == 'ar' ? 'اختر تاريخ الاستحقاق' : 'Select due date';

  // Recurring
  String get recurringTask => locale.languageCode == 'ar' ? 'مهمة متكررة' : 'Recurring Task';
  String get selectPattern => locale.languageCode == 'ar' ? 'اختر النمط' : 'Select pattern';
  String get daily => locale.languageCode == 'ar' ? 'يومياً' : 'Daily';
  String get weekly => locale.languageCode == 'ar' ? 'أسبوعياً' : 'Weekly';
  String get monthly => locale.languageCode == 'ar' ? 'شهرياً' : 'Monthly';

  // Subtasks
  String get subtasks => locale.languageCode == 'ar' ? 'المهام الفرعية' : 'Subtasks';
  String get addSubtask => locale.languageCode == 'ar' ? 'أضف مهمة فرعية...' : 'Add a subtask...';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
