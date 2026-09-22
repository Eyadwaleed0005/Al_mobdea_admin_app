import 'package:al_mobdea_admin/features/students/domain/entities/student_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentEntity', () {
    test('isSubscriptionExpired is true for a past end date', () {
      final student = StudentEntity(
        studentId: 's-1',
        gradeId: 'g-1',
        name: 'Test',
        age: 15,
        email: 'a@b.com',
        phoneNumber: '0100',
        subscriptionStartAt: DateTime(2020, 1, 1),
        subscriptionEndAt: DateTime(2020, 1, 2),
        isActive: true,
        isLoggedIn: false,
      );

      expect(student.isSubscriptionExpired, isTrue);
    });

    test('isSubscriptionExpired is false for a future end date', () {
      final student = StudentEntity(
        studentId: 's-1',
        gradeId: 'g-1',
        name: 'Test',
        age: 15,
        email: 'a@b.com',
        phoneNumber: '0100',
        subscriptionStartAt: DateTime(2020, 1, 1),
        subscriptionEndAt: DateTime(2100, 1, 1),
        isActive: true,
        isLoggedIn: false,
      );

      expect(student.isSubscriptionExpired, isFalse);
    });

    test('copyWith overrides only provided fields', () {
      final student = StudentEntity(
        studentId: 's-1',
        gradeId: 'g-1',
        name: 'Test',
        age: 15,
        email: 'a@b.com',
        phoneNumber: '0100',
        subscriptionStartAt: DateTime(2020, 1, 1),
        subscriptionEndAt: DateTime(2100, 1, 1),
        isActive: true,
        isLoggedIn: false,
      );

      final updated = student.copyWith(name: 'New', isActive: false);

      expect(updated.name, 'New');
      expect(updated.isActive, isFalse);
      expect(updated.studentId, 's-1');
      expect(updated.email, 'a@b.com');
    });
  });
}
