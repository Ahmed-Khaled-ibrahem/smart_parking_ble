bool compareDatesIsEqual(DateTime? d1, DateTime? d2) {
  if (d1 == null && d2 == null) {
    return true;
  }
  if (d1 == null || d2 == null) {
    return false;
  }
  if (d1.second == d2.second &&
      d1.minute == d2.minute &&
      d1.hour == d2.hour &&
      d1.day == d2.day &&
      d1.month == d2.month &&
      d1.year == d2.year) {
    return true;
  }
  return false;
}
