// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      role: $enumDecode(_$AppRoleEnumMap, json['role']),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone': instance.phone,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'role': instance.role,
      'isActive': instance.isActive,
    };

const _$AppRoleEnumMap = {
  AppRole.student: 'student',
  AppRole.teacher: 'teacher',
  AppRole.parent: 'parent',
  AppRole.admin: 'admin',
};
