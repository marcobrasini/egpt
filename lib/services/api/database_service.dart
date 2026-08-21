import "package:egpt/models/member.dart";
import "package:egpt/models/product.dart";
import "package:egpt/models/meeting.dart";
import "package:egpt/models/session.dart";


abstract class DatabaseService {

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

  Future<List<Member>> buildRegister();
  Future<List<Meeting>> buildMeetings();
  Future<List<Session>> buildSessions();

  Future<void> signOut();
  
}