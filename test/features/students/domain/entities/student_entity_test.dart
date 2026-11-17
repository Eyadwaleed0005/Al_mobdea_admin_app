import 'package:al_mobdea_admin/features/students/domain/entities/student_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentEntity', () {
    test('subscription dates are optional', () {
      final student = StudentEntity(
        studentId: 's-1',
        gradeId: 'g-1',
        name: 'Test',
        email: 'a@b.com',
        phoneNumber: '0100',
        isActive: false,
        isLoggedIn: false,
      );

      expect(student.subscriptionStartAt, isNull);
      expect(student.subscriptionEndAt, isNull);
    });

    test('copyWith overrides only provided fields', () {
      final student = StudentEntity(
        studentId: 's-1',
        gradeId: 'g-1',
        name: 'Test',
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
      expect(updated.subscriptionStartAt, DateTime(2020, 1, 1));
      expect(updated.subscriptionEndAt, DateTime(2100, 1, 1));
    });

    test('copyWith can clear both subscription dates', () {
      final student = StudentEntity(
        studentId: 's-1',
        gradeId: 'g-1',
        name: 'Test',
        email: 'a@b.com',
        phoneNumber: '0100',
        subscriptionStartAt: DateTime(2020, 1, 1),
        subscriptionEndAt: DateTime(2100, 1, 1),
        isActive: true,
        isLoggedIn: false,
      );

      final cleared = student.copyWith(clearSubscriptionDates: true);

      expect(cleared.subscriptionStartAt, isNull);
      expect(cleared.subscriptionEndAt, isNull);
      expect(cleared.isActive, isTrue);
    });
  });
}
