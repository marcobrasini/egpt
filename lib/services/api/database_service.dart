import "../../sources/source_database.dart";
import "../../sources/source_register.dart";
import "../../sources/source_schedule.dart";
import "../../sources/source_training.dart";
import "../../models/member.dart";
import "../../models/product.dart";
import "../../models/meeting.dart";
import "../../models/session.dart";


abstract class DatabaseService {
  Future<void> open();
  Future<void> close();
  Future<void> reset();

  Future<Member> createMember(Member member);
  Future<Member> updateMember(Member member);
  Future<Member> deleteMember(Member member);

  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<Product> deleteProduct(Product product);

  Future<Meeting> createMeeting(Meeting meeting);
  Future<Meeting> updateMeeting(Meeting meeting);
  Future<Meeting> deleteMeeting(Meeting meeting);

  Future<Session> createSession(Session session);
  Future<Session> updateSession(Session session);
  Future<Session> deleteSession(Session session);

  Future<void> buildRegister(RegisterSource register);
  Future<void> buildSchedule(ScheduleSource schedule);

  Stream<DatabaseData<Member>> watchMembers(RegisterSource register);
  Stream<DatabaseData<Product>> watchProducts(RegisterSource register);
  Stream<DatabaseData<Meeting>> watchMeetings(ScheduleSource schedule);
  Stream<DatabaseData<Session>> watchSessions(ScheduleSource schedule);
}
