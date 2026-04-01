import 'package:ajenda_app/features/profile/data/models/profile_model.dart';
import 'package:ajenda_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:ajenda_app/features/profile/logic/profile_cubit/profile_cubit.dart';
import 'package:ajenda_app/features/profile/logic/profile_cubit/profile_state.dart';
import 'package:ajenda_app/core/storage/secure_storage_service.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_cubit_test.mocks.dart';

@GenerateMocks([ProfileRepository, SecureStorageService])
void main() {
  late ProfileCubit cubit;
  late MockProfileRepository mockRepo;
  late MockSecureStorageService mockStorage;

  setUp(() {
    mockRepo = MockProfileRepository();
    mockStorage = MockSecureStorageService();
    cubit = ProfileCubit(mockRepo, mockStorage);
  });

  tearDown(() {
    cubit.close();
  });

  final tUpdatedProfile = ProfileModel(
    id: '123',
    firstName: 'John',
    secondName: 'Doe',
    email: 'new@example.com',
  );

  test('confirmChangeEmail should refresh profile and save new email to storage on success', () async {
    // Arrange
    when(mockRepo.confirmChangeEmail(any))
        .thenAnswer((_) async => const Right(null));
    when(mockRepo.getProfile())
        .thenAnswer((_) async => Right(tUpdatedProfile));
    when(mockStorage.saveEmail(any))
        .thenAnswer((_) async => Future.value());

    // Act
    await cubit.confirmChangeEmail(id: '123', newEmail: 'new@example.com', code: '123456');

    // Assert
    verify(mockRepo.confirmChangeEmail(any)).called(1);
    verify(mockRepo.getProfile()).called(1);
    verify(mockStorage.saveEmail('new@example.com')).called(1);

    expect(cubit.state, isA<ConfirmChangeEmailSuccess>());

    // Wait for the delayed ProfileLoaded state
    await Future.delayed(const Duration(milliseconds: 150));
    expect(cubit.state, isA<ProfileLoaded>());
    expect((cubit.state as ProfileLoaded).profile.email, 'new@example.com');
  });
}
