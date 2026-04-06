String timeGreeting([DateTime? now]) {
  final localNow = now ?? DateTime.now();
  final hour = localNow.hour;

  if (hour < 6) return 'Доброй ночи';
  if (hour < 12) return 'Доброе утро';
  if (hour < 18) return 'Добрый день';
  return 'Добрый вечер';
}