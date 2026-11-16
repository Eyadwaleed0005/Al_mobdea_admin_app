import 'package:al_mobdea_admin/features/students/domain/helper/date_validation_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateValidationHelper', () {
    test('isValidDateRange requires the end date to be after the start', () {
      expect(
        DateValidationHelper.isValidDateRange(
          startAt: DateTime(2024, 1, 1),
          endAt: DateTime(2024, 2, 1),
        ),
        isTrue,
      );

      expect(
        DateValidationHelper.isValidDateRange(
          startAt: DateTime(2024, 2, 1),
          endAt: DateTime(2024, 1, 1),
        ),
        isFalse,
      );

      expect(
        DateValidationHelper.isValidDateRange(
          startAt: DateTime(2024, 1, 1),
          endAt: DateTime(2024, 1, 1),
        ),
        isFalse,
      );
    });

    test('isEndDateInFuture reflects the current date', () {
      expect(
        DateValidationHelper.isEndDateInFuture(
          endAt: DateTime(2100, 1, 1),
        ),
        isTrue,
      );

      expect(
        DateValidationHelper.isEndDateInFuture(
          endAt: DateTime(2000, 1, 1),
        ),
        isFalse,
      );
    });

    test('error helpers expose validation errors', () {
      final invalidRange = DateValidationHelper.invalidDateRangeError();

      expect(invalidRange.code, 'invalid-date-range');
      expect(invalidRange.isRetryable, isFalse);

      final expiredDate = DateValidationHelper.expiredEndDateError();

      expect(expiredDate.code, 'expired-end-date');
      expect(expiredDate.isRetryable, isFalse);

      final cannotActivate =
          DateValidationHelper.cannotActivateExpiredSubscriptionError();

      expect(cannotActivate.code, 'expired-subscription');
      expect(cannotActivate.isRetryable, isFalse);
    });
  });
}
