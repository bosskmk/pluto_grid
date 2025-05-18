class TextAdaptiveRow {
  final String question;
  final String test;
  final String id;
  final String name;
  final double age;
  final String role;
  final String joined;
  final String workingTime;
  final int salary;
  final double customRowHeight;

  TextAdaptiveRow({
    this.question = 'test question',
    required this.test,
    required this.id,
    required this.name,
    required this.age,
    required this.role,
    required this.joined,
    required this.workingTime,
    required this.salary,
    this.customRowHeight = 0.0,
  });
}
