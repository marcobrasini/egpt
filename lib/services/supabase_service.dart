// import 'dart:ui';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/models/meeting.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
import 'package:egpt/utils/color.dart';

typedef DataMap = Map<String, dynamic>;


enum AuthRole {
  admin,
  user;

  static AuthRole? parse(String? value) {
    for (final role in AuthRole.values) {
      if (role.name == value) return role;
    }
    return null;
  }
}


class SupabaseService {

  static final _instance = SupabaseService._internal();
  SupabaseService._internal();

  factory SupabaseService() => _instance;

  static final _client = Supabase.instance.client;

  // Authentication methods
  //////////////////////////////////////////////////////////////////////////////
  Session? get session => _client.auth.currentSession;
  User? get user => _client.auth.currentUser;

  Future<String?> signIn({
    required String email, required String password,
  }) async {
    try {
      final result = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (result.user == null) return "Login failed.";
      if (role == null) return "AuthRole error.";
      print(role);
      return null;
    } on AuthException catch (error) {
      return "Supabase error: ${error.message}";
    } catch (error) {
      return "Unexpected error: $error";
    }
  }

  Future<String?> recoverPassword({required String email}) async => null;

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  DataMap? _decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = base64Url.decode(base64Url.normalize(parts[1]));
    return jsonDecode(utf8.decode(payload)) as DataMap;
  }

  AuthRole? get role {
    final token = _client.auth.currentSession?.accessToken;
    if (token == null) return null;
    print(_decode(token));
    return AuthRole.parse(_decode(token)?['auth_role'] as String?);
  }

  bool get privileged => role == AuthRole.admin;

  // Database methods
  static final String _memberColumnId = "id";
  static final String _memberColumnName = "name";
  static final String _memberColumnFirstName = "first_name";
  static final String _memberColumnLastName = "last_name";
  static final String _memberColumnBirth = "birth";
  static final String _memberColumnColor = "color";
  static final String _memberColumnEmail = "email";
  static final String _memberColumnPhone = "phone";
  //static final String _memberColumnPhoto = "photo";
  //
  static final String _productColumnId = "id";
  static final String _productColumnMemberId = "member_id";
  static final String _productColumnSummary = "summary";
  static final String _productColumnLength = "length";
  static final String _productColumnStart = "start";
  static final String _productColumnStop = "stop";

  static final String _meetingColumnId = "id";
  static final String _meetingColumnMemberId = "member_id";
  static final String _meetingColumnProductId = "product_id";
  static final String _meetingColumnStart = "start";
  static final String _meetingColumnStop = "stop";
  static final String _meetingColumnParentId = "recurrence_id";
  static final String _meetingColumnPatternRule = "recurrence_rule";

  DataMap memberToSupabase(Member member) => {
    _memberColumnName: member.name,
    _memberColumnFirstName: member.firstName,
    _memberColumnLastName: member.lastName,
    _memberColumnBirth: member.birth.toString(),
    _memberColumnColor: member.color.toHexString(),
  };

  Member supabaseToMember(DataMap row) => Member(
      id: row[_memberColumnId],
      name: row[_memberColumnName],
      firstName: row[_memberColumnFirstName],
      lastName: row[_memberColumnLastName],
      birth: Date.fromString(row[_memberColumnBirth]),
      color: (row[_memberColumnColor] as String).toColor(),
      email: row[_memberColumnEmail],
      phone: row[_memberColumnPhone],
    );

  DataMap productToSupabase(Product product) => {
    _productColumnMemberId: product.memberId,
    _productColumnSummary: product.summary,
    _productColumnLength: product.length,
    _productColumnStart: product.start.toString(),
    _productColumnStop: product.stop.toString(),
  };

  Product supabaseToProduct(DataMap row) => Product(
    id: row[_productColumnId],
    memberId: row[_productColumnMemberId],
    summary: row[_productColumnSummary],
    length: row[_productColumnLength],
    start: Date.fromString(row[_productColumnStart]),
    stop: Date.fromString(row[_productColumnStop]),
  );

  DataMap meetingToSupabase(Meeting meeting) => {
    _meetingColumnProductId: meeting.product.id,
    _meetingColumnStart: meeting.start.toString(),
    _meetingColumnStop: meeting.stop.toString(),
    _meetingColumnParentId: meeting.parentId,
    _meetingColumnPatternRule: meeting.patternRule,
  };

  Meeting supabaseToMeeting(DataMap row) => Meeting.build(
    id: row[_meetingColumnId],
    memberId: row[_meetingColumnMemberId],
    productId: row[_meetingColumnProductId],
    start: DateTime.parse(row[_meetingColumnStart]),
    stop: DateTime.parse(row[_meetingColumnStop]),
    parentId: row[_meetingColumnParentId],
    patternRule: row[_meetingColumnPatternRule],
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

