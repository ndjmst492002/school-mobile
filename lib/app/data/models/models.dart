class ClassModel {
  final int id;
  final String name;
  final String description;
  final int? teacher;
  final String? teacherName;
  final List<int>? students;
  final int studentCount;

  ClassModel({
    required this.id,
    required this.name,
    required this.description,
    this.teacher,
    this.teacherName,
    this.students,
    this.studentCount = 0,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      teacher: json['teacher'],
      teacherName: json['teacher_name'],
      students: json['students'] != null
          ? List<int>.from(json['students'])
          : null,
      studentCount: json['student_count'] ?? 0,
    );
  }
}

class Exercise {
  final int id;
  final String title;
  final String description;
  final String? fileUrl;
  final int? relatedClass;
  final String? className;
  final String? teacherName;
  final String? dueDate;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    this.fileUrl,
    this.relatedClass,
    this.className,
    this.teacherName,
    this.dueDate,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileUrl: json['file_url'],
      relatedClass: json['related_class'],
      className: json['class_name'],
      teacherName: json['teacher_name'],
      dueDate: json['due_date'],
    );
  }
}

class Submission {
  final int id;
  final int student;
  final String? studentName;
  final int exercise;
  final String exerciseTitle;
  final String? submissionFileUrl;
  final String submittedAt;
  final double? grade;
  final String feedback;

  Submission({
    required this.id,
    required this.student,
    this.studentName,
    required this.exercise,
    required this.exerciseTitle,
    this.submissionFileUrl,
    required this.submittedAt,
    this.grade,
    this.feedback = '',
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] ?? 0,
      student: json['student'] ?? 0,
      studentName: json['student_name'],
      exercise: json['exercise'] ?? 0,
      exerciseTitle: json['exercise_title'] ?? '',
      submissionFileUrl: json['submission_file_url'],
      submittedAt: json['submitted_at'] ?? '',
      grade: json['grade'] != null
          ? (json['grade'] is String
                ? double.tryParse(json['grade'].toString())
                : (json['grade'] as num).toDouble())
          : null,
      feedback: json['feedback'] ?? '',
    );
  }
}

class Announcement {
  final int id;
  final String title;
  final String content;
  final String? teacherName;
  final String? className;
  final String createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.teacherName,
    this.className,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      teacherName: json['teacher_name'],
      className: json['class_name'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
