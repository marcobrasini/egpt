import "../../sources/source_register.dart";
import "../../sources/source_schedule.dart";
import "../../sources/source_training.dart";
import "../../models/member.dart";
import "../../models/product.dart";
import "../../models/meeting.dart";
import "../../models/session.dart";


abstract class DatabaseService {

  Future<Member> createMember(Member member);
  Future<void> updateMember(Member member);
  Future<void> deleteMember(Member member);

  Future<Product> createProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(Product product);

  Future<Meeting> createMeeting(Meeting meeting);
  Future<void> updateMeeting(Meeting meeting);
  Future<void> deleteMeeting(Meeting meeting);

  Future<Session> createSession(Session session);
  Future<void> updateSession(Session session);
  Future<void> deleteSession(Session session);

  Future<void> open();
  Future<void> close();
  Future<void> reset();
  Future<void> buildRegister(RegisterSource register);
  Future<void> buildSchedule(ScheduleSource schedule);
  Future<void> buildTraining(TrainingSource training);
}