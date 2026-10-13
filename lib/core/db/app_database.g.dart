// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $IpoItemsTable extends IpoItems
    with TableInfo<$IpoItemsTable, IpoItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IpoItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _subscribeStartMeta = const VerificationMeta(
    'subscribeStart',
  );
  @override
  late final GeneratedColumn<DateTime> subscribeStart =
      GeneratedColumn<DateTime>(
        'subscribe_start',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _subscribeEndMeta = const VerificationMeta(
    'subscribeEnd',
  );
  @override
  late final GeneratedColumn<DateTime> subscribeEnd = GeneratedColumn<DateTime>(
    'subscribe_end',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refundOnMeta = const VerificationMeta(
    'refundOn',
  );
  @override
  late final GeneratedColumn<DateTime> refundOn = GeneratedColumn<DateTime>(
    'refund_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listOnMeta = const VerificationMeta('listOn');
  @override
  late final GeneratedColumn<DateTime> listOn = GeneratedColumn<DateTime>(
    'list_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _offerPriceMeta = const VerificationMeta(
    'offerPrice',
  );
  @override
  late final GeneratedColumn<int> offerPrice = GeneratedColumn<int>(
    'offer_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _underwriterMeta = const VerificationMeta(
    'underwriter',
  );
  @override
  late final GeneratedColumn<String> underwriter = GeneratedColumn<String>(
    'underwriter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _competitionMeta = const VerificationMeta(
    'competition',
  );
  @override
  late final GeneratedColumn<String> competition = GeneratedColumn<String>(
    'competition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    subscribeStart,
    subscribeEnd,
    refundOn,
    listOn,
    offerPrice,
    underwriter,
    memo,
    createdAt,
    competition,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ipo_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<IpoItemData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('subscribe_start')) {
      context.handle(
        _subscribeStartMeta,
        subscribeStart.isAcceptableOrUnknown(
          data['subscribe_start']!,
          _subscribeStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscribeStartMeta);
    }
    if (data.containsKey('subscribe_end')) {
      context.handle(
        _subscribeEndMeta,
        subscribeEnd.isAcceptableOrUnknown(
          data['subscribe_end']!,
          _subscribeEndMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscribeEndMeta);
    }
    if (data.containsKey('refund_on')) {
      context.handle(
        _refundOnMeta,
        refundOn.isAcceptableOrUnknown(data['refund_on']!, _refundOnMeta),
      );
    }
    if (data.containsKey('list_on')) {
      context.handle(
        _listOnMeta,
        listOn.isAcceptableOrUnknown(data['list_on']!, _listOnMeta),
      );
    }
    if (data.containsKey('offer_price')) {
      context.handle(
        _offerPriceMeta,
        offerPrice.isAcceptableOrUnknown(data['offer_price']!, _offerPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_offerPriceMeta);
    }
    if (data.containsKey('underwriter')) {
      context.handle(
        _underwriterMeta,
        underwriter.isAcceptableOrUnknown(
          data['underwriter']!,
          _underwriterMeta,
        ),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('competition')) {
      context.handle(
        _competitionMeta,
        competition.isAcceptableOrUnknown(
          data['competition']!,
          _competitionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IpoItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IpoItemData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      subscribeStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}subscribe_start'],
      )!,
      subscribeEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}subscribe_end'],
      )!,
      refundOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}refund_on'],
      ),
      listOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}list_on'],
      ),
      offerPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offer_price'],
      )!,
      underwriter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}underwriter'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      competition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}competition'],
      ),
    );
  }

  @override
  $IpoItemsTable createAlias(String alias) {
    return $IpoItemsTable(attachedDatabase, alias);
  }
}

class IpoItemData extends DataClass implements Insertable<IpoItemData> {
  final int id;
  final String name;
  final DateTime subscribeStart;
  final DateTime subscribeEnd;
  final DateTime? refundOn;
  final DateTime? listOn;

  /// 공모가 (원)
  final int offerPrice;
  final String? underwriter;
  final String? memo;
  final DateTime createdAt;

  /// 청약 경쟁률. 사이트에 적힌 글자 그대로 ('685:1')
  final String? competition;
  const IpoItemData({
    required this.id,
    required this.name,
    required this.subscribeStart,
    required this.subscribeEnd,
    this.refundOn,
    this.listOn,
    required this.offerPrice,
    this.underwriter,
    this.memo,
    required this.createdAt,
    this.competition,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['subscribe_start'] = Variable<DateTime>(subscribeStart);
    map['subscribe_end'] = Variable<DateTime>(subscribeEnd);
    if (!nullToAbsent || refundOn != null) {
      map['refund_on'] = Variable<DateTime>(refundOn);
    }
    if (!nullToAbsent || listOn != null) {
      map['list_on'] = Variable<DateTime>(listOn);
    }
    map['offer_price'] = Variable<int>(offerPrice);
    if (!nullToAbsent || underwriter != null) {
      map['underwriter'] = Variable<String>(underwriter);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || competition != null) {
      map['competition'] = Variable<String>(competition);
    }
    return map;
  }

  IpoItemsCompanion toCompanion(bool nullToAbsent) {
    return IpoItemsCompanion(
      id: Value(id),
      name: Value(name),
      subscribeStart: Value(subscribeStart),
      subscribeEnd: Value(subscribeEnd),
      refundOn: refundOn == null && nullToAbsent
          ? const Value.absent()
          : Value(refundOn),
      listOn: listOn == null && nullToAbsent
          ? const Value.absent()
          : Value(listOn),
      offerPrice: Value(offerPrice),
      underwriter: underwriter == null && nullToAbsent
          ? const Value.absent()
          : Value(underwriter),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
      competition: competition == null && nullToAbsent
          ? const Value.absent()
          : Value(competition),
    );
  }

  factory IpoItemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IpoItemData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      subscribeStart: serializer.fromJson<DateTime>(json['subscribeStart']),
      subscribeEnd: serializer.fromJson<DateTime>(json['subscribeEnd']),
      refundOn: serializer.fromJson<DateTime?>(json['refundOn']),
      listOn: serializer.fromJson<DateTime?>(json['listOn']),
      offerPrice: serializer.fromJson<int>(json['offerPrice']),
      underwriter: serializer.fromJson<String?>(json['underwriter']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      competition: serializer.fromJson<String?>(json['competition']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'subscribeStart': serializer.toJson<DateTime>(subscribeStart),
      'subscribeEnd': serializer.toJson<DateTime>(subscribeEnd),
      'refundOn': serializer.toJson<DateTime?>(refundOn),
      'listOn': serializer.toJson<DateTime?>(listOn),
      'offerPrice': serializer.toJson<int>(offerPrice),
      'underwriter': serializer.toJson<String?>(underwriter),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'competition': serializer.toJson<String?>(competition),
    };
  }

  IpoItemData copyWith({
    int? id,
    String? name,
    DateTime? subscribeStart,
    DateTime? subscribeEnd,
    Value<DateTime?> refundOn = const Value.absent(),
    Value<DateTime?> listOn = const Value.absent(),
    int? offerPrice,
    Value<String?> underwriter = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    DateTime? createdAt,
    Value<String?> competition = const Value.absent(),
  }) => IpoItemData(
    id: id ?? this.id,
    name: name ?? this.name,
    subscribeStart: subscribeStart ?? this.subscribeStart,
    subscribeEnd: subscribeEnd ?? this.subscribeEnd,
    refundOn: refundOn.present ? refundOn.value : this.refundOn,
    listOn: listOn.present ? listOn.value : this.listOn,
    offerPrice: offerPrice ?? this.offerPrice,
    underwriter: underwriter.present ? underwriter.value : this.underwriter,
    memo: memo.present ? memo.value : this.memo,
    createdAt: createdAt ?? this.createdAt,
    competition: competition.present ? competition.value : this.competition,
  );
  IpoItemData copyWithCompanion(IpoItemsCompanion data) {
    return IpoItemData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      subscribeStart: data.subscribeStart.present
          ? data.subscribeStart.value
          : this.subscribeStart,
      subscribeEnd: data.subscribeEnd.present
          ? data.subscribeEnd.value
          : this.subscribeEnd,
      refundOn: data.refundOn.present ? data.refundOn.value : this.refundOn,
      listOn: data.listOn.present ? data.listOn.value : this.listOn,
      offerPrice: data.offerPrice.present
          ? data.offerPrice.value
          : this.offerPrice,
      underwriter: data.underwriter.present
          ? data.underwriter.value
          : this.underwriter,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      competition: data.competition.present
          ? data.competition.value
          : this.competition,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IpoItemData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('subscribeStart: $subscribeStart, ')
          ..write('subscribeEnd: $subscribeEnd, ')
          ..write('refundOn: $refundOn, ')
          ..write('listOn: $listOn, ')
          ..write('offerPrice: $offerPrice, ')
          ..write('underwriter: $underwriter, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('competition: $competition')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    subscribeStart,
    subscribeEnd,
    refundOn,
    listOn,
    offerPrice,
    underwriter,
    memo,
    createdAt,
    competition,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IpoItemData &&
          other.id == this.id &&
          other.name == this.name &&
          other.subscribeStart == this.subscribeStart &&
          other.subscribeEnd == this.subscribeEnd &&
          other.refundOn == this.refundOn &&
          other.listOn == this.listOn &&
          other.offerPrice == this.offerPrice &&
          other.underwriter == this.underwriter &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt &&
          other.competition == this.competition);
}

class IpoItemsCompanion extends UpdateCompanion<IpoItemData> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> subscribeStart;
  final Value<DateTime> subscribeEnd;
  final Value<DateTime?> refundOn;
  final Value<DateTime?> listOn;
  final Value<int> offerPrice;
  final Value<String?> underwriter;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  final Value<String?> competition;
  const IpoItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.subscribeStart = const Value.absent(),
    this.subscribeEnd = const Value.absent(),
    this.refundOn = const Value.absent(),
    this.listOn = const Value.absent(),
    this.offerPrice = const Value.absent(),
    this.underwriter = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.competition = const Value.absent(),
  });
  IpoItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime subscribeStart,
    required DateTime subscribeEnd,
    this.refundOn = const Value.absent(),
    this.listOn = const Value.absent(),
    required int offerPrice,
    this.underwriter = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.competition = const Value.absent(),
  }) : name = Value(name),
       subscribeStart = Value(subscribeStart),
       subscribeEnd = Value(subscribeEnd),
       offerPrice = Value(offerPrice);
  static Insertable<IpoItemData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? subscribeStart,
    Expression<DateTime>? subscribeEnd,
    Expression<DateTime>? refundOn,
    Expression<DateTime>? listOn,
    Expression<int>? offerPrice,
    Expression<String>? underwriter,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
    Expression<String>? competition,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (subscribeStart != null) 'subscribe_start': subscribeStart,
      if (subscribeEnd != null) 'subscribe_end': subscribeEnd,
      if (refundOn != null) 'refund_on': refundOn,
      if (listOn != null) 'list_on': listOn,
      if (offerPrice != null) 'offer_price': offerPrice,
      if (underwriter != null) 'underwriter': underwriter,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
      if (competition != null) 'competition': competition,
    });
  }

  IpoItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? subscribeStart,
    Value<DateTime>? subscribeEnd,
    Value<DateTime?>? refundOn,
    Value<DateTime?>? listOn,
    Value<int>? offerPrice,
    Value<String?>? underwriter,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
    Value<String?>? competition,
  }) {
    return IpoItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      subscribeStart: subscribeStart ?? this.subscribeStart,
      subscribeEnd: subscribeEnd ?? this.subscribeEnd,
      refundOn: refundOn ?? this.refundOn,
      listOn: listOn ?? this.listOn,
      offerPrice: offerPrice ?? this.offerPrice,
      underwriter: underwriter ?? this.underwriter,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      competition: competition ?? this.competition,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (subscribeStart.present) {
      map['subscribe_start'] = Variable<DateTime>(subscribeStart.value);
    }
    if (subscribeEnd.present) {
      map['subscribe_end'] = Variable<DateTime>(subscribeEnd.value);
    }
    if (refundOn.present) {
      map['refund_on'] = Variable<DateTime>(refundOn.value);
    }
    if (listOn.present) {
      map['list_on'] = Variable<DateTime>(listOn.value);
    }
    if (offerPrice.present) {
      map['offer_price'] = Variable<int>(offerPrice.value);
    }
    if (underwriter.present) {
      map['underwriter'] = Variable<String>(underwriter.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (competition.present) {
      map['competition'] = Variable<String>(competition.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IpoItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('subscribeStart: $subscribeStart, ')
          ..write('subscribeEnd: $subscribeEnd, ')
          ..write('refundOn: $refundOn, ')
          ..write('listOn: $listOn, ')
          ..write('offerPrice: $offerPrice, ')
          ..write('underwriter: $underwriter, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('competition: $competition')
          ..write(')'))
        .toString();
  }
}

class $IpoRecordsTable extends IpoRecords
    with TableInfo<$IpoRecordsTable, IpoRecordData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IpoRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ipo_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _accountNameMeta = const VerificationMeta(
    'accountName',
  );
  @override
  late final GeneratedColumn<String> accountName = GeneratedColumn<String>(
    'account_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('기본계좌'),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _depositMeta = const VerificationMeta(
    'deposit',
  );
  @override
  late final GeneratedColumn<int> deposit = GeneratedColumn<int>(
    'deposit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allottedMeta = const VerificationMeta(
    'allotted',
  );
  @override
  late final GeneratedColumn<int> allotted = GeneratedColumn<int>(
    'allotted',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soldPriceMeta = const VerificationMeta(
    'soldPrice',
  );
  @override
  late final GeneratedColumn<int> soldPrice = GeneratedColumn<int>(
    'sold_price',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<int> fee = GeneratedColumn<int>(
    'fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _soldOnMeta = const VerificationMeta('soldOn');
  @override
  late final GeneratedColumn<DateTime> soldOn = GeneratedColumn<DateTime>(
    'sold_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    accountName,
    quantity,
    deposit,
    allotted,
    soldPrice,
    fee,
    soldOn,
    memo,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ipo_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<IpoRecordData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('account_name')) {
      context.handle(
        _accountNameMeta,
        accountName.isAcceptableOrUnknown(
          data['account_name']!,
          _accountNameMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('deposit')) {
      context.handle(
        _depositMeta,
        deposit.isAcceptableOrUnknown(data['deposit']!, _depositMeta),
      );
    } else if (isInserting) {
      context.missing(_depositMeta);
    }
    if (data.containsKey('allotted')) {
      context.handle(
        _allottedMeta,
        allotted.isAcceptableOrUnknown(data['allotted']!, _allottedMeta),
      );
    }
    if (data.containsKey('sold_price')) {
      context.handle(
        _soldPriceMeta,
        soldPrice.isAcceptableOrUnknown(data['sold_price']!, _soldPriceMeta),
      );
    }
    if (data.containsKey('fee')) {
      context.handle(
        _feeMeta,
        fee.isAcceptableOrUnknown(data['fee']!, _feeMeta),
      );
    }
    if (data.containsKey('sold_on')) {
      context.handle(
        _soldOnMeta,
        soldOn.isAcceptableOrUnknown(data['sold_on']!, _soldOnMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IpoRecordData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IpoRecordData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      accountName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      deposit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deposit'],
      )!,
      allotted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}allotted'],
      ),
      soldPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sold_price'],
      ),
      fee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee'],
      )!,
      soldOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sold_on'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IpoRecordsTable createAlias(String alias) {
    return $IpoRecordsTable(attachedDatabase, alias);
  }
}

class IpoRecordData extends DataClass implements Insertable<IpoRecordData> {
  final int id;
  final int itemId;

  /// 계좌명/증권사 (예: '한투(본인)', 'KB(가족)') - 자유 텍스트
  final String accountName;

  /// 청약 수량 (주)
  final int quantity;

  /// 증거금 (원)
  final int deposit;

  /// 배정 수량 (주). 발표 전이면 null
  final int? allotted;

  /// 매도 단가 (원). 아직 안 팔았으면 null
  final int? soldPrice;

  /// 수수료 (원)
  final int fee;
  final DateTime? soldOn;
  final String? memo;
  final DateTime createdAt;
  const IpoRecordData({
    required this.id,
    required this.itemId,
    required this.accountName,
    required this.quantity,
    required this.deposit,
    this.allotted,
    this.soldPrice,
    required this.fee,
    this.soldOn,
    this.memo,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_id'] = Variable<int>(itemId);
    map['account_name'] = Variable<String>(accountName);
    map['quantity'] = Variable<int>(quantity);
    map['deposit'] = Variable<int>(deposit);
    if (!nullToAbsent || allotted != null) {
      map['allotted'] = Variable<int>(allotted);
    }
    if (!nullToAbsent || soldPrice != null) {
      map['sold_price'] = Variable<int>(soldPrice);
    }
    map['fee'] = Variable<int>(fee);
    if (!nullToAbsent || soldOn != null) {
      map['sold_on'] = Variable<DateTime>(soldOn);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IpoRecordsCompanion toCompanion(bool nullToAbsent) {
    return IpoRecordsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      accountName: Value(accountName),
      quantity: Value(quantity),
      deposit: Value(deposit),
      allotted: allotted == null && nullToAbsent
          ? const Value.absent()
          : Value(allotted),
      soldPrice: soldPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(soldPrice),
      fee: Value(fee),
      soldOn: soldOn == null && nullToAbsent
          ? const Value.absent()
          : Value(soldOn),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
    );
  }

  factory IpoRecordData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IpoRecordData(
      id: serializer.fromJson<int>(json['id']),
      itemId: serializer.fromJson<int>(json['itemId']),
      accountName: serializer.fromJson<String>(json['accountName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      deposit: serializer.fromJson<int>(json['deposit']),
      allotted: serializer.fromJson<int?>(json['allotted']),
      soldPrice: serializer.fromJson<int?>(json['soldPrice']),
      fee: serializer.fromJson<int>(json['fee']),
      soldOn: serializer.fromJson<DateTime?>(json['soldOn']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemId': serializer.toJson<int>(itemId),
      'accountName': serializer.toJson<String>(accountName),
      'quantity': serializer.toJson<int>(quantity),
      'deposit': serializer.toJson<int>(deposit),
      'allotted': serializer.toJson<int?>(allotted),
      'soldPrice': serializer.toJson<int?>(soldPrice),
      'fee': serializer.toJson<int>(fee),
      'soldOn': serializer.toJson<DateTime?>(soldOn),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IpoRecordData copyWith({
    int? id,
    int? itemId,
    String? accountName,
    int? quantity,
    int? deposit,
    Value<int?> allotted = const Value.absent(),
    Value<int?> soldPrice = const Value.absent(),
    int? fee,
    Value<DateTime?> soldOn = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    DateTime? createdAt,
  }) => IpoRecordData(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    accountName: accountName ?? this.accountName,
    quantity: quantity ?? this.quantity,
    deposit: deposit ?? this.deposit,
    allotted: allotted.present ? allotted.value : this.allotted,
    soldPrice: soldPrice.present ? soldPrice.value : this.soldPrice,
    fee: fee ?? this.fee,
    soldOn: soldOn.present ? soldOn.value : this.soldOn,
    memo: memo.present ? memo.value : this.memo,
    createdAt: createdAt ?? this.createdAt,
  );
  IpoRecordData copyWithCompanion(IpoRecordsCompanion data) {
    return IpoRecordData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      accountName: data.accountName.present
          ? data.accountName.value
          : this.accountName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      deposit: data.deposit.present ? data.deposit.value : this.deposit,
      allotted: data.allotted.present ? data.allotted.value : this.allotted,
      soldPrice: data.soldPrice.present ? data.soldPrice.value : this.soldPrice,
      fee: data.fee.present ? data.fee.value : this.fee,
      soldOn: data.soldOn.present ? data.soldOn.value : this.soldOn,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IpoRecordData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('accountName: $accountName, ')
          ..write('quantity: $quantity, ')
          ..write('deposit: $deposit, ')
          ..write('allotted: $allotted, ')
          ..write('soldPrice: $soldPrice, ')
          ..write('fee: $fee, ')
          ..write('soldOn: $soldOn, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    accountName,
    quantity,
    deposit,
    allotted,
    soldPrice,
    fee,
    soldOn,
    memo,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IpoRecordData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.accountName == this.accountName &&
          other.quantity == this.quantity &&
          other.deposit == this.deposit &&
          other.allotted == this.allotted &&
          other.soldPrice == this.soldPrice &&
          other.fee == this.fee &&
          other.soldOn == this.soldOn &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt);
}

class IpoRecordsCompanion extends UpdateCompanion<IpoRecordData> {
  final Value<int> id;
  final Value<int> itemId;
  final Value<String> accountName;
  final Value<int> quantity;
  final Value<int> deposit;
  final Value<int?> allotted;
  final Value<int?> soldPrice;
  final Value<int> fee;
  final Value<DateTime?> soldOn;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  const IpoRecordsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.accountName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.deposit = const Value.absent(),
    this.allotted = const Value.absent(),
    this.soldPrice = const Value.absent(),
    this.fee = const Value.absent(),
    this.soldOn = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  IpoRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int itemId,
    this.accountName = const Value.absent(),
    required int quantity,
    required int deposit,
    this.allotted = const Value.absent(),
    this.soldPrice = const Value.absent(),
    this.fee = const Value.absent(),
    this.soldOn = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : itemId = Value(itemId),
       quantity = Value(quantity),
       deposit = Value(deposit);
  static Insertable<IpoRecordData> custom({
    Expression<int>? id,
    Expression<int>? itemId,
    Expression<String>? accountName,
    Expression<int>? quantity,
    Expression<int>? deposit,
    Expression<int>? allotted,
    Expression<int>? soldPrice,
    Expression<int>? fee,
    Expression<DateTime>? soldOn,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (accountName != null) 'account_name': accountName,
      if (quantity != null) 'quantity': quantity,
      if (deposit != null) 'deposit': deposit,
      if (allotted != null) 'allotted': allotted,
      if (soldPrice != null) 'sold_price': soldPrice,
      if (fee != null) 'fee': fee,
      if (soldOn != null) 'sold_on': soldOn,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  IpoRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? itemId,
    Value<String>? accountName,
    Value<int>? quantity,
    Value<int>? deposit,
    Value<int?>? allotted,
    Value<int?>? soldPrice,
    Value<int>? fee,
    Value<DateTime?>? soldOn,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
  }) {
    return IpoRecordsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      accountName: accountName ?? this.accountName,
      quantity: quantity ?? this.quantity,
      deposit: deposit ?? this.deposit,
      allotted: allotted ?? this.allotted,
      soldPrice: soldPrice ?? this.soldPrice,
      fee: fee ?? this.fee,
      soldOn: soldOn ?? this.soldOn,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (accountName.present) {
      map['account_name'] = Variable<String>(accountName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (deposit.present) {
      map['deposit'] = Variable<int>(deposit.value);
    }
    if (allotted.present) {
      map['allotted'] = Variable<int>(allotted.value);
    }
    if (soldPrice.present) {
      map['sold_price'] = Variable<int>(soldPrice.value);
    }
    if (fee.present) {
      map['fee'] = Variable<int>(fee.value);
    }
    if (soldOn.present) {
      map['sold_on'] = Variable<DateTime>(soldOn.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IpoRecordsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('accountName: $accountName, ')
          ..write('quantity: $quantity, ')
          ..write('deposit: $deposit, ')
          ..write('allotted: $allotted, ')
          ..write('soldPrice: $soldPrice, ')
          ..write('fee: $fee, ')
          ..write('soldOn: $soldOn, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IpoItemsTable ipoItems = $IpoItemsTable(this);
  late final $IpoRecordsTable ipoRecords = $IpoRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [ipoItems, ipoRecords];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ipo_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ipo_records', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$IpoItemsTableCreateCompanionBuilder =
    IpoItemsCompanion Function({
      Value<int> id,
      required String name,
      required DateTime subscribeStart,
      required DateTime subscribeEnd,
      Value<DateTime?> refundOn,
      Value<DateTime?> listOn,
      required int offerPrice,
      Value<String?> underwriter,
      Value<String?> memo,
      Value<DateTime> createdAt,
      Value<String?> competition,
    });
typedef $$IpoItemsTableUpdateCompanionBuilder =
    IpoItemsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> subscribeStart,
      Value<DateTime> subscribeEnd,
      Value<DateTime?> refundOn,
      Value<DateTime?> listOn,
      Value<int> offerPrice,
      Value<String?> underwriter,
      Value<String?> memo,
      Value<DateTime> createdAt,
      Value<String?> competition,
    });

final class $$IpoItemsTableReferences
    extends BaseReferences<_$AppDatabase, $IpoItemsTable, IpoItemData> {
  $$IpoItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$IpoRecordsTable, List<IpoRecordData>>
  _ipoRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ipoRecords,
    aliasName: 'ipo_items__id__ipo_records__item_id',
  );

  $$IpoRecordsTableProcessedTableManager get ipoRecordsRefs {
    final manager = $$IpoRecordsTableTableManager(
      $_db,
      $_db.ipoRecords,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ipoRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IpoItemsTableFilterComposer
    extends Composer<_$AppDatabase, $IpoItemsTable> {
  $$IpoItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get subscribeStart => $composableBuilder(
    column: $table.subscribeStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get subscribeEnd => $composableBuilder(
    column: $table.subscribeEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get refundOn => $composableBuilder(
    column: $table.refundOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get listOn => $composableBuilder(
    column: $table.listOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offerPrice => $composableBuilder(
    column: $table.offerPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get underwriter => $composableBuilder(
    column: $table.underwriter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get competition => $composableBuilder(
    column: $table.competition,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ipoRecordsRefs(
    Expression<bool> Function($$IpoRecordsTableFilterComposer f) f,
  ) {
    final $$IpoRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ipoRecords,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IpoRecordsTableFilterComposer(
            $db: $db,
            $table: $db.ipoRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IpoItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $IpoItemsTable> {
  $$IpoItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get subscribeStart => $composableBuilder(
    column: $table.subscribeStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get subscribeEnd => $composableBuilder(
    column: $table.subscribeEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get refundOn => $composableBuilder(
    column: $table.refundOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get listOn => $composableBuilder(
    column: $table.listOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offerPrice => $composableBuilder(
    column: $table.offerPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get underwriter => $composableBuilder(
    column: $table.underwriter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get competition => $composableBuilder(
    column: $table.competition,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IpoItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IpoItemsTable> {
  $$IpoItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get subscribeStart => $composableBuilder(
    column: $table.subscribeStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get subscribeEnd => $composableBuilder(
    column: $table.subscribeEnd,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get refundOn =>
      $composableBuilder(column: $table.refundOn, builder: (column) => column);

  GeneratedColumn<DateTime> get listOn =>
      $composableBuilder(column: $table.listOn, builder: (column) => column);

  GeneratedColumn<int> get offerPrice => $composableBuilder(
    column: $table.offerPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get underwriter => $composableBuilder(
    column: $table.underwriter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get competition => $composableBuilder(
    column: $table.competition,
    builder: (column) => column,
  );

  Expression<T> ipoRecordsRefs<T extends Object>(
    Expression<T> Function($$IpoRecordsTableAnnotationComposer a) f,
  ) {
    final $$IpoRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ipoRecords,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IpoRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.ipoRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IpoItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IpoItemsTable,
          IpoItemData,
          $$IpoItemsTableFilterComposer,
          $$IpoItemsTableOrderingComposer,
          $$IpoItemsTableAnnotationComposer,
          $$IpoItemsTableCreateCompanionBuilder,
          $$IpoItemsTableUpdateCompanionBuilder,
          (IpoItemData, $$IpoItemsTableReferences),
          IpoItemData,
          PrefetchHooks Function({bool ipoRecordsRefs})
        > {
  $$IpoItemsTableTableManager(_$AppDatabase db, $IpoItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IpoItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IpoItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IpoItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> subscribeStart = const Value.absent(),
                Value<DateTime> subscribeEnd = const Value.absent(),
                Value<DateTime?> refundOn = const Value.absent(),
                Value<DateTime?> listOn = const Value.absent(),
                Value<int> offerPrice = const Value.absent(),
                Value<String?> underwriter = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> competition = const Value.absent(),
              }) => IpoItemsCompanion(
                id: id,
                name: name,
                subscribeStart: subscribeStart,
                subscribeEnd: subscribeEnd,
                refundOn: refundOn,
                listOn: listOn,
                offerPrice: offerPrice,
                underwriter: underwriter,
                memo: memo,
                createdAt: createdAt,
                competition: competition,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime subscribeStart,
                required DateTime subscribeEnd,
                Value<DateTime?> refundOn = const Value.absent(),
                Value<DateTime?> listOn = const Value.absent(),
                required int offerPrice,
                Value<String?> underwriter = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> competition = const Value.absent(),
              }) => IpoItemsCompanion.insert(
                id: id,
                name: name,
                subscribeStart: subscribeStart,
                subscribeEnd: subscribeEnd,
                refundOn: refundOn,
                listOn: listOn,
                offerPrice: offerPrice,
                underwriter: underwriter,
                memo: memo,
                createdAt: createdAt,
                competition: competition,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IpoItemsTable, IpoItemData>(table),
                  $$IpoItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ipoRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ipoRecordsRefs) db.ipoRecords],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ipoRecordsRefs)
                    await $_getPrefetchedData<
                      IpoItemData,
                      $IpoItemsTable,
                      IpoRecordData
                    >(
                      currentTable: table,
                      referencedTable: $$IpoItemsTableReferences
                          ._ipoRecordsRefsTable(db),
                      managerFromTypedResult: (p0) => $$IpoItemsTableReferences(
                        db,
                        table,
                        p0,
                      ).ipoRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$IpoItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IpoItemsTable,
      IpoItemData,
      $$IpoItemsTableFilterComposer,
      $$IpoItemsTableOrderingComposer,
      $$IpoItemsTableAnnotationComposer,
      $$IpoItemsTableCreateCompanionBuilder,
      $$IpoItemsTableUpdateCompanionBuilder,
      (IpoItemData, $$IpoItemsTableReferences),
      IpoItemData,
      PrefetchHooks Function({bool ipoRecordsRefs})
    >;
typedef $$IpoRecordsTableCreateCompanionBuilder =
    IpoRecordsCompanion Function({
      Value<int> id,
      required int itemId,
      Value<String> accountName,
      required int quantity,
      required int deposit,
      Value<int?> allotted,
      Value<int?> soldPrice,
      Value<int> fee,
      Value<DateTime?> soldOn,
      Value<String?> memo,
      Value<DateTime> createdAt,
    });
typedef $$IpoRecordsTableUpdateCompanionBuilder =
    IpoRecordsCompanion Function({
      Value<int> id,
      Value<int> itemId,
      Value<String> accountName,
      Value<int> quantity,
      Value<int> deposit,
      Value<int?> allotted,
      Value<int?> soldPrice,
      Value<int> fee,
      Value<DateTime?> soldOn,
      Value<String?> memo,
      Value<DateTime> createdAt,
    });

final class $$IpoRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $IpoRecordsTable, IpoRecordData> {
  $$IpoRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $IpoItemsTable _itemIdTable(_$AppDatabase db) =>
      db.ipoItems.createAlias('ipo_records__item_id__ipo_items__id');

  $$IpoItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$IpoItemsTableTableManager(
      $_db,
      $_db.ipoItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IpoRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $IpoRecordsTable> {
  $$IpoRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deposit => $composableBuilder(
    column: $table.deposit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get allotted => $composableBuilder(
    column: $table.allotted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get soldPrice => $composableBuilder(
    column: $table.soldPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get soldOn => $composableBuilder(
    column: $table.soldOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$IpoItemsTableFilterComposer get itemId {
    final $$IpoItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.ipoItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IpoItemsTableFilterComposer(
            $db: $db,
            $table: $db.ipoItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IpoRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $IpoRecordsTable> {
  $$IpoRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deposit => $composableBuilder(
    column: $table.deposit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get allotted => $composableBuilder(
    column: $table.allotted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get soldPrice => $composableBuilder(
    column: $table.soldPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get soldOn => $composableBuilder(
    column: $table.soldOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$IpoItemsTableOrderingComposer get itemId {
    final $$IpoItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.ipoItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IpoItemsTableOrderingComposer(
            $db: $db,
            $table: $db.ipoItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IpoRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IpoRecordsTable> {
  $$IpoRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get deposit =>
      $composableBuilder(column: $table.deposit, builder: (column) => column);

  GeneratedColumn<int> get allotted =>
      $composableBuilder(column: $table.allotted, builder: (column) => column);

  GeneratedColumn<int> get soldPrice =>
      $composableBuilder(column: $table.soldPrice, builder: (column) => column);

  GeneratedColumn<int> get fee =>
      $composableBuilder(column: $table.fee, builder: (column) => column);

  GeneratedColumn<DateTime> get soldOn =>
      $composableBuilder(column: $table.soldOn, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$IpoItemsTableAnnotationComposer get itemId {
    final $$IpoItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.ipoItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IpoItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.ipoItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IpoRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IpoRecordsTable,
          IpoRecordData,
          $$IpoRecordsTableFilterComposer,
          $$IpoRecordsTableOrderingComposer,
          $$IpoRecordsTableAnnotationComposer,
          $$IpoRecordsTableCreateCompanionBuilder,
          $$IpoRecordsTableUpdateCompanionBuilder,
          (IpoRecordData, $$IpoRecordsTableReferences),
          IpoRecordData,
          PrefetchHooks Function({bool itemId})
        > {
  $$IpoRecordsTableTableManager(_$AppDatabase db, $IpoRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IpoRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IpoRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IpoRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<String> accountName = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> deposit = const Value.absent(),
                Value<int?> allotted = const Value.absent(),
                Value<int?> soldPrice = const Value.absent(),
                Value<int> fee = const Value.absent(),
                Value<DateTime?> soldOn = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => IpoRecordsCompanion(
                id: id,
                itemId: itemId,
                accountName: accountName,
                quantity: quantity,
                deposit: deposit,
                allotted: allotted,
                soldPrice: soldPrice,
                fee: fee,
                soldOn: soldOn,
                memo: memo,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int itemId,
                Value<String> accountName = const Value.absent(),
                required int quantity,
                required int deposit,
                Value<int?> allotted = const Value.absent(),
                Value<int?> soldPrice = const Value.absent(),
                Value<int> fee = const Value.absent(),
                Value<DateTime?> soldOn = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => IpoRecordsCompanion.insert(
                id: id,
                itemId: itemId,
                accountName: accountName,
                quantity: quantity,
                deposit: deposit,
                allotted: allotted,
                soldPrice: soldPrice,
                fee: fee,
                soldOn: soldOn,
                memo: memo,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IpoRecordsTable, IpoRecordData>(table),
                  $$IpoRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: $$IpoRecordsTableReferences
                                    ._itemIdTable(db),
                                referencedColumn: $$IpoRecordsTableReferences
                                    ._itemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IpoRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IpoRecordsTable,
      IpoRecordData,
      $$IpoRecordsTableFilterComposer,
      $$IpoRecordsTableOrderingComposer,
      $$IpoRecordsTableAnnotationComposer,
      $$IpoRecordsTableCreateCompanionBuilder,
      $$IpoRecordsTableUpdateCompanionBuilder,
      (IpoRecordData, $$IpoRecordsTableReferences),
      IpoRecordData,
      PrefetchHooks Function({bool itemId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IpoItemsTableTableManager get ipoItems =>
      $$IpoItemsTableTableManager(_db, _db.ipoItems);
  $$IpoRecordsTableTableManager get ipoRecords =>
      $$IpoRecordsTableTableManager(_db, _db.ipoRecords);
}
