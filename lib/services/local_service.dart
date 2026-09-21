import 'package:calendar/calendar.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/sqlite3.dart' as sql;
import 'package:uuid/uuid.dart';
import '../models/member.dart';
import '../models/product.dart';
import '../models/session.dart';
import '../models/meeting.dart';
import '../utils/color.dart';
import '../typedef.dart';


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

  static Product productFromLocal(DataMap row) => Product.build(
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
  static const sessionColumnMemberId = "member_id";
  static const sessionColumnProductId = "product_id";
  static const sessionColumnStart = "start";
  static const sessionColumnStop = "stop";
  static const sessionColumnPresence = "presence";

  static DataMap sessionToLocal(
    Session session, {
    String? id,
    bool make = false,
  }) => {
    if (make) sessionColumnId: id ?? session.id,
    if (make) sessionColumnProductId: session.product.id,
    sessionColumnStart: session.start.toString(),
    sessionColumnStop: session.stop.toString(),
    sessionColumnPresence: session.presence,
  };

  static Session sessionFromLocal(DataMap row) => Session.build(
    id: row[sessionColumnId],
    productId: row[sessionColumnProductId],
    start: DateTime.parse(row[sessionColumnStart]),
    stop: DateTime.parse(row[sessionColumnStop]),
    presence: row[sessionColumnPresence] > 0,
  );

  // Meeting ─────────────────────────────────────────────────────────────────
  static const meetingTable = "meetings";
  static const meetingColumnId = "id";
  static const meetingColumnProductId = "product_id";
  static const meetingColumnStart = "start";
  static const meetingColumnStop = "stop";
  static const meetingColumnParentId = "recurrence_id";
  static const meetingColumnPatternRule = "recurrence_rule";

  static DataMap meetingToLocal(
    Meeting meeting, {
    String? id,
    bool make = false,
  }) => {
    if (make) meetingColumnId: id ?? meeting.id,
    if (make) meetingColumnProductId: meeting.product.id,
    meetingColumnStart: meeting.start.toString(),
    meetingColumnStop: meeting.stop.toString(),
    meetingColumnParentId: meeting.parentId,
    meetingColumnPatternRule: meeting.patternRule,
  };

  static Meeting meetingFromLocal(DataMap row) => Meeting.build(
    id: row[meetingColumnId],
    productId: row[meetingColumnProductId],
    parentId: row[meetingColumnParentId],
    start: DateTime.parse(row[meetingColumnStart]),
    stop: DateTime.parse(row[meetingColumnStop]),
    patternRule: row[meetingColumnPatternRule],
  );
}
