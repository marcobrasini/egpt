// import 'dart:ui';
import 'package:egpt/models/meeting.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
import 'package:egpt/utils/datetime.dart';
import 'package:egpt/utils/color.dart';

typedef DataMap = Map<String, dynamic>;


class SupabaseService {

  static final _instance = SupabaseService._internal();
  SupabaseService._internal();

  factory SupabaseService() => _instance;

  static final _client = Supabase.instance.client;
  static final Map<String, String> _roles = {};

  // Authentication methods
  //////////////////////////////////////////////////////////////////////////////
  Session? get session => _client.auth.currentSession;
  User? get user => _client.auth.currentUser;

  Future<String?> signIn({
    required String email,
    required String password,
  }) async
  {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return (res.user == null) ? "Login failed." : null;
    } on AuthException catch (error) {
      return "Supabase error: ${error.message}";
    } catch (error) {
      return "Unexpected error: $error";
    }
  }

  Future<String?> recoverPassword({
      required String email
  }) async => null;

  Future<void> signOut() async =>
      await _client.auth.signOut();

  Future<String?> get role async {
    try {
      if (user == null) return null;
      if (_roles.containsKey(user!.id)) return _roles[user!.id];
      final res = await _client
          .from("logins").select("auth_role")
          .eq("auth_id", user!.id)
          .single();
      _roles[user!.id] = res["auth_role"];
      return _roles[user!.id];
    } on PostgrestException catch (error) {
      return "Supabase error: ${error.message}";
    } catch (error) {
      return "Unexpected error: $error";
    }
  }

  Future<bool?> get privileged async {
    final permission = await role;
    return permission == "admin";
  }

  // Database methods
  static final String _userTable = "users";
  static final String _userColumn_memberId = "member_id";
  static final String _userColumn_user_id = "auth_id";
  //////////////////////////////////////////////////////////////////////////////
  static final String _memberTable = "members";
  static final String _memberColumn_id = "id";
  static final String _memberColumn_name = "name";
  static final String _memberColumn_firstName = "first_name";
  static final String _memberColumn_lastName = "last_name";
  static final String _memberColumn_birth = "birth";
  static final String _memberColumn_color = "color";
  static final String _memberColumn_email = "email";
  static final String _memberColumn_phone = "phone";
  //static final String _memberColumn_photo = "photo";
  //
  static final String _productTable = "products";
  static final String _productColumn_id = "id";
  static final String _productColumn_memberId = "member_id";
  static final String _productColumn_summary = "summary";
  static final String _productColumn_length = "length";
  static final String _productColumn_start = "start";
  static final String _productColumn_stop = "stop";

  static final String _meetingTable = "products";
  static final String _meetingColumn_id = "id";
  static final String _meetingColumn_memberId = "member_id";
  static final String _meetingColumn_productId = "product_id";
  static final String _meetingColumn_start = "start";
  static final String _meetingColumn_stop = "stop";
  static final String _meetingColumn_recurrenceId = "recurrence_id";
  static final String _meetingColumn_recurrenceRule = "recurrence_rule";
  static final String _meetingColumn_exceptionsList = "exceptions_list";

  DataMap memberToSupabase(Member member) => {
    _memberColumn_name: member.name,
    _memberColumn_firstName: member.firstName,
    _memberColumn_lastName: member.lastName,
    _memberColumn_birth: member.birth.toString(),
    _memberColumn_color: member.color.toHexString(),
  };

  Member supabaseToMember(DataMap row) => Member(
      id: row[_memberColumn_id],
      name: row[_memberColumn_name],
      firstName: row[_memberColumn_firstName],
      lastName: row[_memberColumn_lastName],
      birth: Date.fromString(row[_memberColumn_birth]),
      color: (row[_memberColumn_color] as String).toColor(),
      email: row[_memberColumn_email],
      phone: row[_memberColumn_phone],
    );

  DataMap productToSupabase(Product product) => {
    _productColumn_memberId: product.memberId,
    _productColumn_summary: product.summary,
    _productColumn_length: product.length,
    _productColumn_start: product.start.toString(),
    _productColumn_stop: product.stop.toString(),
  };

  Product supabaseToProduct(DataMap row) => Product(
    id: row[_productColumn_id],
    memberId: row[_productColumn_memberId],
    summary: row[_productColumn_summary],
    length: row[_productColumn_length],
    start: Date.fromString(row[_productColumn_start]),
    stop: Date.fromString(row[_productColumn_stop]),
  );

  DataMap meetingToSupabase(Meeting meeting) => {
    _meetingColumn_productId: meeting.product.id,
    _meetingColumn_start: meeting.start.toString(),
    _meetingColumn_stop: meeting.stop.toString(),
    _meetingColumn_recurrenceId: meeting.recurrenceId,
    _meetingColumn_recurrenceRule: meeting.recurrenceRule,
    _meetingColumn_exceptionsList: meeting.exceptionsList
        .map((m) => m.toString()).toList(),
  };

  Meeting supabaseToMeeting(DataMap row) => Meeting.build(
      id: row[_meetingColumn_id],
      memberId: row[_meetingColumn_memberId],
      productId: row[_meetingColumn_productId],
      start: DateTime.parse(row[_meetingColumn_start]),
      stop: DateTime.parse(row[_meetingColumn_stop]),
      recurrenceId: row[_meetingColumn_recurrenceId],
      recurrenceRule: row[_meetingColumn_recurrenceRule],
      exceptionsList: Set<Date>.from(
          row[_meetingColumn_exceptionsList]?.map(
              (date) => Date.fromString(date)
          ) ?? []),
  );

  Future<List<Member>> buildRegister() async {
    final register = await _client.rpc('get_register');
    final List<Member> members = [];
    for (final row in register) {
      final member = supabaseToMember(row["member"]);
      if (row["products"] != null) {
        for (final sub in row["products"]) {
          member.products.add(supabaseToProduct(sub));
        }
      }
      members.add(member);
    }
    return members;
  }

  Future<List<Meeting>> buildSchedule() async {
    final schedule = await _client.rpc('get_schedule');
    final List<Meeting> meeting = [];
    for (final row in schedule) {
      meeting.add(supabaseToMeeting(row));
    }
    return meeting;
  }

  Future<Member> createMember(Member member) async {
    final data = memberToSupabase(member);
    final id = await _client.rpc(
      "add_member", params: {
        'p_member': data,
        'p_user_id': null,
      });
    return Member.make(id: id, data: member.get());
  }

  Future<Member> updateMember(Member member) async {
    await _client.rpc(
      "set_member", params: {
        'p_member_id': member.id,
        'p_member': memberToSupabase(member),
    });
    return member;
  }

  Future<Member> deleteMember(Member member) async {
    await _client.rpc(
      "del_member", params: {
        'p_member_id': member.id,
    });
    return member;
  }

  Future<Product> createProduct(Product product) async {
    final data = productToSupabase(product);
    final id = await _client.rpc(
      "add_product", params: {
        'p_product': data,
    });
    return Product.make(id: id, data: product.get());
  }

  Future<Product> updateProduct(Product product) async {
    await _client.rpc(
    "set_product", params: {
      'p_product_id': product.id,
      'p_product': productToSupabase(product),
    });
    return product;
  }

  Future<Product> deleteProduct(Product product) async {
    await _client.rpc(
        "del_product", params: {
      'p_product_id': product.id,
    });
    return product;
  }

  Future<Meeting> createMeeting(Meeting meeting) async {
    final data = meetingToSupabase(meeting);
    final id = await _client.rpc(
        "add_meeting", params: {
      'p_meeting': data,
    });
    return Meeting.make(id: id, data: meeting.get());
  }

  Future<Meeting> updateMeeting(Meeting meeting) async {
    await _client.rpc(
        "set_meeting", params: {
      'p_meeting_id': meeting.id,
      'p_meeting': meetingToSupabase(meeting),
    });
    return meeting;
  }

  Future<Meeting> deleteMeeting(Meeting meeting) async {
    await _client.rpc(
        "del_meeting", params: {
      'p_meeting_id': meeting.id,
    });
    return meeting;
  }
}

