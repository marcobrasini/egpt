// import 'dart:async';
//
// import 'package:egpt/models/member.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// part 'register_event.dart';
// part 'register_state.dart';
//
//
// abstract class RegisterRepository {
//   FutureOr<List<Member>> fetchMembers();
//   FutureOr<Member> removeMember(Member member);
// }
//
//
// class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
//   final RegisterRepository repository;
//
//   RegisterBloc({required this.repository}) : super(const RegisterState()) {
//     on<RegisterBuilt>(_onBuilt);
//     on<RegisterSearched>((event, emit) =>
//         emit(state.copyWith(pattern: event.pattern)));
//     on<RegisterMemberInserted>(_onInserted);
//     on<RegisterMemberRemoved>(_onRemoved);
//   }
//
//   static List<Member> _sorted(Iterable<Member> members) =>
//       members.toList()..sort((a, b) => a.name.compareTo(b.name));
//
//   Future<void> _onBuilt(RegisterBuilt event, Emitter<RegisterState> emit) async {
//     emit(state.copyWith(status: RegisterStatus.load));
//     try {
//       final members = await repository.fetchMembers();
//       emit(state.copyWith(
//         members: _sorted(members),
//         status: RegisterStatus.safe,
//       ));
//     } catch (error) {
//       emit(state.copyWith(
//         status: RegisterStatus.fail,
//         error: error.toString(),
//       ));
//     }
//   }
//
//   /// Il salvataggio lo fa il bloc del form: qui si allinea solo la lista.
//   void _onInserted(RegisterMemberInserted event, Emitter<RegisterState> emit) {
//     final members = List<Member>.from(state.members);
//     final index = members.indexWhere((m) => m.id == event.member.id);
//     if (index < 0) {
//       members.add(event.member);
//     } else {
//       members[index] = event.member;
//     }
//     emit(state.copyWith(members: _sorted(members)));
//   }
//
//   Future<void> _onRemoved(RegisterMemberRemoved event, Emitter<RegisterState> emit) async {
//     emit(state.copyWith(status: RegisterStatus.load));
//     try {
//       await repository.removeMember(event.member);
//       emit(state.copyWith(
//         members: state.members.where((m) => m.id != event.member.id).toList(),
//         status: RegisterStatus.safe,
//       ));
//     } catch (error) {
//       emit(state.copyWith(
//         status: RegisterStatus.fail,
//         error: error.toString(),
//       ));
//     }
//   }
// }
