import 'dart:convert';
import 'package:egpt/services/api/auth_service.dart';
import 'package:egpt/services/api/database_service.dart';
import 'package:egpt/services/api/provider_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:calendar/calendar.dart';
import 'package:egpt/models/meeting.dart';
import 'package:egpt/models/member.dart';
import 'package:egpt/models/product.dart';
import 'package:egpt/utils/color.dart';


typedef DataMap = Map<String, dynamic>;


class SupabaseService implements DatabaseService, AuthService {

  static OAuthProvider _oAuth(ProviderService provider) =>
      switch (provider.identity) {
        ProviderIdentity.google => OAuthProvider.google,
        ProviderIdentity.apple  => OAuthProvider.apple,
      };
  static final instance = SupabaseService._singleton();
  SupabaseService._singleton();

  factory SupabaseService() => instance;
  final client = Supabase.instance.client;
  Session? get session => client.auth.currentSession;
  User? get user => client.auth.currentUser;

  @override
  Future<String?> signInWith(ProviderService provider) async {
    try {
      final tokens = await provider.authenticate();
      await client.auth.signInWithIdToken(
        provider: _oAuth(provider),
        idToken: tokens.identityToken,
        accessToken: tokens.accessToken,
        nonce: tokens.rawNonce,
      );
      if (user == null) return "Login failed.";
      if (role == null) return "User role undefined.";
      return null;
    } on IdentityCancelled catch (error) {
      return error.toString();
    } on IdentityFailure catch (error) {
      return error.message;
    } on AuthException catch (error) {
      return "Authentication error: ${error.message}";
    } catch (error) {
      return "Unexpected error: $error";
    }
  }

  @override
  Future<String?> signIn({
    required String email, required String password,
  }) async {
    try {
      final result = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (result.user == null) return "Login failed.";
      if (role == null) return "User role undefined.";
      return null;
    } on AuthException catch (error) {
      return "Authentication error: ${error.message}";
    } catch (error) {
      return "Unexpected error: $error";
    }
  }

  @override
  Future<String?> recoverPassword({required String email}) async => null;

  @override
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  @override
  AuthRole? get role {
    final token = client.auth.currentSession?.accessToken;
    if (token == null) return null;
    return AuthRole.parse(_decode(token)?['auth_role'] as String?);
  }

  @override
  bool get privileged => role == AuthRole.admin;

  DataMap? _decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = base64Url.decode(base64Url.normalize(parts[1]));
    return jsonDecode(utf8.decode(payload)) as DataMap;
  }

  // Member ──────────────────────────────────────────────────────────────────
  static final String _memberColumnId = "id";
  static final String _memberColumnName = "name";
  static final String _memberColumnFirstName = "first_name";
  static final String _memberColumnLastName = "last_name";
  static final String _memberColumnBirth = "birth";
  static final String _memberColumnColor = "color";
  static final String _memberColumnEmail = "email";
  static final String _memberColumnPhone = "phone";
  //static final String _memberColumnPhoto = "photo";

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

  @override
  Future<Member> createMember(Member member) async {
    final data = memberToSupabase(member);
    final id = await client.rpc(
      "add_member", params: {
        'p_member': data,
        'p_user_id': null,
      });
    return Member.make(id: id, data: member.get());
  }

  @override
  Future<Member> updateMember(Member member) async {
    await client.rpc(
      "set_member", params: {
        'p_member_id': member.id,
        'p_member': memberToSupabase(member),
    });
    return member;
  }

  @override
  Future<Member> deleteMember(Member member) async {
    await client.rpc(
      "del_member", params: {
        'p_member_id': member.id,
    });
    return member;
  }

  // Product ─────────────────────────────────────────────────────────────────
  static final String _productColumnId = "id";
  static final String _productColumnMemberId = "member_id";
  static final String _productColumnSummary = "summary";
  static final String _productColumnLength = "length";
  static final String _productColumnStart = "start";
  static final String _productColumnStop = "stop";

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

  @override
  Future<Product> createProduct(Product product) async {
    final data = productToSupabase(product);
    final id = await client.rpc(
      "add_product", params: {
        'p_product': data,
    });
    return Product.make(id: id, data: product.get());
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await client.rpc(
    "set_product", params: {
      'p_product_id': product.id,
      'p_product': productToSupabase(product),
    });
    return product;
  }

  @override
  Future<Product> deleteProduct(Product product) async {
    await client.rpc(
        "del_product", params: {
      'p_product_id': product.id,
    });
    return product;
  }

  // Meeting ─────────────────────────────────────────────────────────────────
  static final String _meetingColumnId = "id";
  static final String _meetingColumnMemberId = "member_id";
  static final String _meetingColumnProductId = "product_id";
  static final String _meetingColumnStart = "start";
  static final String _meetingColumnStop = "stop";
  static final String _meetingColumnParentId = "recurrence_id";
  static final String _meetingColumnPatternRule = "recurrence_rule";

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

  @override
  Future<Meeting> createMeeting(Meeting meeting) async {
    final data = meetingToSupabase(meeting);
    final id = await client.rpc(
        "add_meeting", params: {
      'p_meeting': data,
    });
    return Meeting.make(id: id, data: meeting.get());
  }

  @override
  Future<Meeting> updateMeeting(Meeting meeting) async {
    await client.rpc(
        "set_meeting", params: {
      'p_meeting_id': meeting.id,
      'p_meeting': meetingToSupabase(meeting),
    });
    return meeting;
  }

  @override
  Future<Meeting> deleteMeeting(Meeting meeting) async {
    await client.rpc(
        "del_meeting", params: {
      'p_meeting_id': meeting.id,
    });
    return meeting;
  }

  // Admin ───────────────────────────────────────────────────────────────────
  @override
  Future<List<Member>> buildRegister() async {
    final register = await client.rpc('get_register');
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

  @override
  Future<List<Meeting>> buildSchedule() async {
    final schedule = await client.rpc('get_schedule');
    final List<Meeting> meeting = [];
    for (final row in schedule) {
      meeting.add(supabaseToMeeting(row));
    }
    return meeting;
  }
}

