// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRoutineModelCollection on Isar {
  IsarCollection<RoutineModel> get routineModels => this.collection();
}

const RoutineModelSchema = CollectionSchema(
  name: r'RoutineModel',
  id: -1626869750065799181,
  properties: {
    r'isCompleted': PropertySchema(
      id: 0,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'lastChecked': PropertySchema(
      id: 1,
      name: r'lastChecked',
      type: IsarType.dateTime,
    ),
    r'timeOfDay': PropertySchema(
      id: 2,
      name: r'timeOfDay',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 3,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _routineModelEstimateSize,
  serialize: _routineModelSerialize,
  deserialize: _routineModelDeserialize,
  deserializeProp: _routineModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _routineModelGetId,
  getLinks: _routineModelGetLinks,
  attach: _routineModelAttach,
  version: '3.1.0+1',
);

int _routineModelEstimateSize(
  RoutineModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.timeOfDay.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _routineModelSerialize(
  RoutineModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isCompleted);
  writer.writeDateTime(offsets[1], object.lastChecked);
  writer.writeString(offsets[2], object.timeOfDay);
  writer.writeString(offsets[3], object.title);
}

RoutineModel _routineModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RoutineModel();
  object.id = id;
  object.isCompleted = reader.readBool(offsets[0]);
  object.lastChecked = reader.readDateTime(offsets[1]);
  object.timeOfDay = reader.readString(offsets[2]);
  object.title = reader.readString(offsets[3]);
  return object;
}

P _routineModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _routineModelGetId(RoutineModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _routineModelGetLinks(RoutineModel object) {
  return [];
}

void _routineModelAttach(
    IsarCollection<dynamic> col, Id id, RoutineModel object) {
  object.id = id;
}

extension RoutineModelQueryWhereSort
    on QueryBuilder<RoutineModel, RoutineModel, QWhere> {
  QueryBuilder<RoutineModel, RoutineModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RoutineModelQueryWhere
    on QueryBuilder<RoutineModel, RoutineModel, QWhereClause> {
  QueryBuilder<RoutineModel, RoutineModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<RoutineModel, RoutineModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterWhereClause> idBetween(
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

extension RoutineModelQueryFilter
    on QueryBuilder<RoutineModel, RoutineModel, QFilterCondition> {
  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      lastCheckedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastChecked',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      lastCheckedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastChecked',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      lastCheckedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastChecked',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      lastCheckedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastChecked',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      timeOfDayEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeOfDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      timeOfDayGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeOfDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      timeOfDayLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeOfDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      timeOfDayBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeOfDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      timeOfDayStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'timeOfDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      timeOfDayEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'timeOfDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      timeOfDayContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'timeOfDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      timeOfDayMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'timeOfDay',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      timeOfDayIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeOfDay',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      timeOfDayIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'timeOfDay',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension RoutineModelQueryObject
    on QueryBuilder<RoutineModel, RoutineModel, QFilterCondition> {}

extension RoutineModelQueryLinks
    on QueryBuilder<RoutineModel, RoutineModel, QFilterCondition> {}

extension RoutineModelQuerySortBy
    on QueryBuilder<RoutineModel, RoutineModel, QSortBy> {
  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByLastChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastChecked', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy>
      sortByLastCheckedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastChecked', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByTimeOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeOfDay', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByTimeOfDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeOfDay', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension RoutineModelQuerySortThenBy
    on QueryBuilder<RoutineModel, RoutineModel, QSortThenBy> {
  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByLastChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastChecked', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy>
      thenByLastCheckedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastChecked', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByTimeOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeOfDay', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByTimeOfDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeOfDay', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension RoutineModelQueryWhereDistinct
    on QueryBuilder<RoutineModel, RoutineModel, QDistinct> {
  QueryBuilder<RoutineModel, RoutineModel, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QDistinct> distinctByLastChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastChecked');
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QDistinct> distinctByTimeOfDay(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeOfDay', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension RoutineModelQueryProperty
    on QueryBuilder<RoutineModel, RoutineModel, QQueryProperty> {
  QueryBuilder<RoutineModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RoutineModel, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<RoutineModel, DateTime, QQueryOperations> lastCheckedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastChecked');
    });
  }

  QueryBuilder<RoutineModel, String, QQueryOperations> timeOfDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeOfDay');
    });
  }

  QueryBuilder<RoutineModel, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
