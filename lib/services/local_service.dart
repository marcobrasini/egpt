import 'package:calendar/calendar.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:egpt/models/models.dart';
import 'package:egpt/style.dart';
import 'package:egpt/types.dart';


typedef Database = sql.Database;


class LocalService {

  // Member ──────────────────────────────────────────────────────────────────
  static const String memberTable = "members";
  static const String memberColumnId = "id";
  static const String memberColumnName = "name";
  static const String memberColumnFirstName = "first_name";
  static const String memberColumnLastName = "last_name";
  static const String memberColumnBirth = "birth";
  static const String memberColumnColor = "color";
  static const String memberColumnEmail = "email";
  static const String memberColumnPhone = "phone";
  //static const memberColumnPhoto = "photo";

  static DataMap memberToLocal(
    Member member, {
    String? id,
    bool make = false,
  }) => {
    if (make) memberColumnId: id ?? member.id,
    memberColumnName: member.name,
    memberColumnFirstName: member.firstName,
    memberColumnLastName: member.lastName,
    memberColumnColor: member.color.toHexString(),
    memberColumnBirth: member.birth.toString(),
    memberColumnEmail: member.email,
    memberColumnPhone: member.phone,
  };

  static Member memberFromLocal(DataMap row) => Member(
    id: row[memberColumnId],
    name: row[memberColumnName],
    firstName: row[memberColumnFirstName],
    lastName: row[memberColumnLastName],
    color: (row[memberColumnColor] as String).toColor(),
    birth: Date.fromString(row[memberColumnBirth]),
    email: row[memberColumnEmail],
    phone: row[memberColumnPhone],
  );

  // Product ─────────────────────────────────────────────────────────────────
  static const String productTable = "products";
  static const String productColumnId = "id";
  static const String productColumnMemberId = "member_id";
  static const String productColumnSummary = "summary";
  static const String productColumnLength = "length";
  static const String productColumnStart = "start";
  static const String productColumnStop = "stop";

  static DataMap productToLocal(
    Product product, {
    String? id,
    bool make = false,
  }) => {
    if (make) productColumnId: id ?? product.id,
    if (make) productColumnMemberId: product.member.id,
    productColumnSummary: product.summary,
    productColumnLength: product.length,
    productColumnStart: product.start.toString(),
    productColumnStop: product.stop.toString(),
  };

  static Product productFromLocal(DataMap row) => Product(
    id: row[productColumnId],
    memberId: row[productColumnMemberId],
    summary: row[productColumnSummary],
    length: row[productColumnLength],
    start: Date.fromString(row[productColumnStart]),
    stop: Date.fromString(row[productColumnStop]),
  );

  // Session ─────────────────────────────────────────────────────────────────
  static const sessionTable = "sessions";
  static const sessionColumnId = "id";
  static const sessionColumnProductId = "product_id";

  static DataMap sessionToLocal(
      Session session, {
        String? id,
        bool make = false,
      }) => {
    if (make) sessionColumnId: id ?? session.id,
    if (make) sessionColumnProductId: session.productId,
  };

  static Session sessionFromLocal(DataMap row) => Session.build(
    id: row[sessionColumnId],
    productId: row[sessionColumnProductId],
  );

  // Presence ─────────────────────────────────────────────────────────────────
  static const presenceTable = "presences";
  static const presenceColumnId = "id";
  static const presenceColumnProductId = "product_id";
  static const presenceColumnPresence = "presence";
  static const presenceColumnStart = "start";
  static const presenceColumnStop = "stop";

  static DataMap presenceToLocal(
    Presence presence, {
    String? id,
    bool make = false,
  }) => {
    if (make) presenceColumnId: id ?? presence.id,
    if (make) presenceColumnProductId: presence.product.id,
    presenceColumnStart: presence.start.fromTZ().toString(),
    presenceColumnStop: presence.stop.fromTZ().toString(),
    presenceColumnPresence: presence.presence,
  };

  static Presence presenceFromLocal(DataMap row) => Presence(
    id: row[presenceColumnId],
    productId: row[presenceColumnProductId],
    start: DateTime.parse(row[presenceColumnStart]).toTZ(),
    stop: DateTime.parse(row[presenceColumnStop]).toTZ(),
    presence: row[presenceColumnPresence] > 0,
  );

  // Meeting ─────────────────────────────────────────────────────────────────
  static const meetingTable = "meetings";
  static const meetingColumnId = "id";
  static const meetingColumnProductId = "product_id";
  static const meetingColumnPatternRule = "recurrence_rule";
  static const meetingColumnParentId = "recurrence_id";
  static const meetingColumnStart = "start";
  static const meetingColumnStop = "stop";

  static DataMap meetingToLocal(
    Meeting meeting, {
    String? id,
    bool make = false,
  }) => {
    if (make) meetingColumnId: id ?? meeting.id,
    if (make) meetingColumnProductId: meeting.product.id,
    meetingColumnStart: meeting.start.fromTZ().toString(),
    meetingColumnStop: meeting.stop.fromTZ().toString(),
    meetingColumnParentId: meeting.parentId,
    meetingColumnPatternRule: meeting.patternRule,
  };

  static Meeting meetingFromLocal(DataMap row) {
    print(row);
    return Meeting(
      id: row[meetingColumnId],
      productId: row[meetingColumnProductId],
      parentId: row[meetingColumnParentId],
      start: DateTime.parse(row[meetingColumnStart]).toTZ(),
      stop: DateTime.parse(row[meetingColumnStop]).toTZ(),
      pattern: (row[meetingColumnPatternRule] != null)
          ? Pattern.fromICSString(row[meetingColumnPatternRule])
          : null,
    );
  }
}
