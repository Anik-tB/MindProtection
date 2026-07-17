// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sobriety_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSobrietyModelCollection on Isar {
  IsarCollection<SobrietyModel> get sobrietyModels => this.collection();
}

const SobrietyModelSchema = CollectionSchema(
  name: r'SobrietyModel',
  id: -692405536330027864,
  properties: {
    r'currentStreakDays': PropertySchema(
      id: 0,
      name: r'currentStreakDays',
      type: IsarType.long,
    ),
    r'longestStreakDays': PropertySchema(
      id: 1,
      name: r'longestStreakDays',
      type: IsarType.long,
    ),
    r'relapseDates': PropertySchema(
      id: 2,
      name: r'relapseDates',
      type: IsarType.dateTimeList,
    ),
    r'sobrietyStartDate': PropertySchema(
      id: 3,
      name: r'sobrietyStartDate',
      type: IsarType.dateTime,
    ),
    r'triggersLog': PropertySchema(
      id: 4,
      name: r'triggersLog',
      type: IsarType.stringList,
    )
  },
  estimateSize: _sobrietyModelEstimateSize,
  serialize: _sobrietyModelSerialize,
  deserialize: _sobrietyModelDeserialize,
  deserializeProp: _sobrietyModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _sobrietyModelGetId,
  getLinks: _sobrietyModelGetLinks,
  attach: _sobrietyModelAttach,
  version: '3.1.0+1',
);

int _sobrietyModelEstimateSize(
  SobrietyModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.relapseDates;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final list = object.triggersLog;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  return bytesCount;
}

void _sobrietyModelSerialize(
  SobrietyModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentStreakDays);
  writer.writeLong(offsets[1], object.longestStreakDays);
  writer.writeDateTimeList(offsets[2], object.relapseDates);
  writer.writeDateTime(offsets[3], object.sobrietyStartDate);
  writer.writeStringList(offsets[4], object.triggersLog);
}

SobrietyModel _sobrietyModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SobrietyModel();
  object.currentStreakDays = reader.readLong(offsets[0]);
  object.id = id;
  object.longestStreakDays = reader.readLong(offsets[1]);
  object.relapseDates = reader.readDateTimeList(offsets[2]);
  object.sobrietyStartDate = reader.readDateTime(offsets[3]);
  object.triggersLog = reader.readStringList(offsets[4]);
  return object;
}

P _sobrietyModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeList(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringList(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sobrietyModelGetId(SobrietyModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sobrietyModelGetLinks(SobrietyModel object) {
  return [];
}

void _sobrietyModelAttach(
    IsarCollection<dynamic> col, Id id, SobrietyModel object) {
  object.id = id;
}

extension SobrietyModelQueryWhereSort
    on QueryBuilder<SobrietyModel, SobrietyModel, QWhere> {
  QueryBuilder<SobrietyModel, SobrietyModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SobrietyModelQueryWhere
    on QueryBuilder<SobrietyModel, SobrietyModel, QWhereClause> {
  QueryBuilder<SobrietyModel, SobrietyModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SobrietyModelQueryFilter
    on QueryBuilder<SobrietyModel, SobrietyModel, QFilterCondition> {
  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      currentStreakDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      currentStreakDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      currentStreakDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      currentStreakDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStreakDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      longestStreakDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longestStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      longestStreakDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longestStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      longestStreakDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longestStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      longestStreakDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longestStreakDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      relapseDatesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'relapseDates',
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      relapseDatesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'relapseDates',
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      relapseDatesElementEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relapseDates',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      relapseDatesElementGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relapseDates',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      relapseDatesElementLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relapseDates',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      relapseDatesElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relapseDates',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      relapseDatesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relapseDates',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      relapseDatesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relapseDates',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      relapseDatesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relapseDates',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      relapseDatesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relapseDates',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      relapseDatesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relapseDates',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      relapseDatesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relapseDates',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      sobrietyStartDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sobrietyStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      sobrietyStartDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sobrietyStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      sobrietyStartDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sobrietyStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      sobrietyStartDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sobrietyStartDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'triggersLog',
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'triggersLog',
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggersLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'triggersLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'triggersLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'triggersLog',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'triggersLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'triggersLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'triggersLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'triggersLog',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggersLog',
        value: '',
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'triggersLog',
        value: '',
      ));
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggersLog',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggersLog',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggersLog',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggersLog',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggersLog',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterFilterCondition>
      triggersLogLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggersLog',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension SobrietyModelQueryObject
    on QueryBuilder<SobrietyModel, SobrietyModel, QFilterCondition> {}

extension SobrietyModelQueryLinks
    on QueryBuilder<SobrietyModel, SobrietyModel, QFilterCondition> {}

extension SobrietyModelQuerySortBy
    on QueryBuilder<SobrietyModel, SobrietyModel, QSortBy> {
  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy>
      sortByCurrentStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreakDays', Sort.asc);
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy>
      sortByCurrentStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreakDays', Sort.desc);
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy>
      sortByLongestStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakDays', Sort.asc);
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy>
      sortByLongestStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakDays', Sort.desc);
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy>
      sortBySobrietyStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sobrietyStartDate', Sort.asc);
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy>
      sortBySobrietyStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sobrietyStartDate', Sort.desc);
    });
  }
}

extension SobrietyModelQuerySortThenBy
    on QueryBuilder<SobrietyModel, SobrietyModel, QSortThenBy> {
  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy>
      thenByCurrentStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreakDays', Sort.asc);
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy>
      thenByCurrentStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreakDays', Sort.desc);
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy>
      thenByLongestStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakDays', Sort.asc);
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy>
      thenByLongestStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakDays', Sort.desc);
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy>
      thenBySobrietyStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sobrietyStartDate', Sort.asc);
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QAfterSortBy>
      thenBySobrietyStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sobrietyStartDate', Sort.desc);
    });
  }
}

extension SobrietyModelQueryWhereDistinct
    on QueryBuilder<SobrietyModel, SobrietyModel, QDistinct> {
  QueryBuilder<SobrietyModel, SobrietyModel, QDistinct>
      distinctByCurrentStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreakDays');
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QDistinct>
      distinctByLongestStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longestStreakDays');
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QDistinct>
      distinctByRelapseDates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relapseDates');
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QDistinct>
      distinctBySobrietyStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sobrietyStartDate');
    });
  }

  QueryBuilder<SobrietyModel, SobrietyModel, QDistinct>
      distinctByTriggersLog() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggersLog');
    });
  }
}

extension SobrietyModelQueryProperty
    on QueryBuilder<SobrietyModel, SobrietyModel, QQueryProperty> {
  QueryBuilder<SobrietyModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SobrietyModel, int, QQueryOperations>
      currentStreakDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreakDays');
    });
  }

  QueryBuilder<SobrietyModel, int, QQueryOperations>
      longestStreakDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longestStreakDays');
    });
  }

  QueryBuilder<SobrietyModel, List<DateTime>?, QQueryOperations>
      relapseDatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relapseDates');
    });
  }

  QueryBuilder<SobrietyModel, DateTime, QQueryOperations>
      sobrietyStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sobrietyStartDate');
    });
  }

  QueryBuilder<SobrietyModel, List<String>?, QQueryOperations>
      triggersLogProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggersLog');
    });
  }
}
