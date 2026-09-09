// part of 'member_bloc.dart';
//
//
// enum MemberStatus { safe, load, fail }
//
//
// class MemberState extends Equatable {
//   final Member? member;
//   final bool editing;
//   final bool naming;
//   final MemberStatus status;
//   final String? error;
//
//   const MemberState({
//     this.member,
//     this.editing = false,
//     this.naming = false,
//     this.status = MemberStatus.safe,
//     this.error,
//   });
//
//   factory MemberState.safe({Member? member}) => MemberState(
//     member: member,
//     editing: member == null,
//     status: MemberStatus.safe
//   );
//
//   MemberState copyWith({
//     Member? member,
//     MemberStatus? status,
//     bool? enabled,
//     bool? editing,
//     bool? naming,
//     String? error,
//   }) => MemberState(
//     member: member ?? this.member,
//     editing: editing ?? this.editing,
//     naming: naming ?? this.naming,
//     status: status ?? this.status,
//     error: error,
//   );
//
//   @override
//   List<Object?> get props => [
//     member,
//     editing,
//     naming,
//     status,
//     error,
//   ];
// }
