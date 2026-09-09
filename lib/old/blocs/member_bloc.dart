// import 'dart:async';
// import 'dart:ui';
//
// import 'package:calendar/calendar.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:egpt/models/member.dart';
// import 'package:egpt/typedef.dart';
//
// part 'member_event.dart';
// part 'member_state.dart';
//
//
// class MemberBloc extends Bloc<MemberEvent, MemberState> {
//
//   MemberBloc({
//     Member? member,
//   }) : super(MemberState.safe(member: member)) {
//     on<MemberNameChanged>((event, emit) {
//       final member = state.member?.set({"name": event.name});
//       emit(state.copyWith(member: member));
//     });
//     on<MemberFirstNameChanged>((event, emit) {
//       final member = state.member?.set({"firstName": event.firstName});
//       emit(state.copyWith(member: member));
//     });
//     on<MemberLastNameChanged>((event, emit) {
//       final member = state.member?.set({"lastName": event.lastName});
//       emit(state.copyWith(member: member));
//     });
//     on<MemberColorChanged>((event, emit) {
//       final member = state.member?.set({"color": event.color});
//       emit(state.copyWith(member: member));
//     });
//     on<MemberBirthChanged>((event, emit) {
//       final member = state.member?.set({"birth": event.birth});
//       emit(state.copyWith(member: member));
//     });
//     on<MemberEmailChanged>((event, emit) {
//       final member = state.member?.set({"email": event.email});
//       emit(state.copyWith(member: member));
//     });
//     on<MemberPhoneChanged>((event, emit) {
//       final member = state.member?.set({"phone": event.phone});
//       emit(state.copyWith(member: member));
//     });
//     on<MemberEditing>((event, emit) =>
//         emit(state.copyWith(editing: event.editing))
//     );
//     on<MemberNaming>((event, emit) =>
//         emit(state.copyWith(naming: !state.naming))
//     );
//     on<MemberSubmitted>(_onSubmitted);
//   }
//
//   Future<void> _onSubmitted(
//       MemberSubmitted event,
//       Emitter<MemberState> emit,
//   ) async {
//     emit(state.copyWith(status: MemberStatus.load));
//     try {
//       final member = (state.member == null)
//           ? Member.make(data: event.data)
//           : state.member!.set(event.data);
//       // final saved = (state.member?.id == null)
//       //     ? await repository.insertMember(member)
//       //     : await repository.modifyMember(member);
//       // emit(state.copyWith(
//       //   member: saved ?? member,
//       //   editing: false,
//       //   status: MemberStatus.safe,
//       // ));
//     } catch (error) {
//       emit(state.copyWith(
//         status: MemberStatus.fail,
//         error: error.toString(),
//       ));
//     }
//   }
//
// }
