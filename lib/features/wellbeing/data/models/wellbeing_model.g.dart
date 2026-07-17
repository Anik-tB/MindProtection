// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wellbeing_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWellbeingLogModelCollection on Isar {
  IsarCollection<WellbeingLogModel> get wellbeingLogModels => this.collection();
}

const WellbeingLogModelSchema = CollectionSchema(
  name: r'WellbeingLogModel',
  id: 7676402548984013767,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'moodRating': PropertySchema(
      id: 1,
      name: r'moodRating',
      type: IsarType.long,
    ),
    r'sleepDurationHours': PropertySchema(
      id: 2,
      name: r'sleepDurationHours',
      type: IsarType.double,
    ),
    r'waterIntakeLiters': PropertySchema(
      id: 3,
      name: r'waterIntakeLiters',
      type: IsarType.double,
    )
  },
  estimateSize: _wellbeingLogModelEstimateSize,
  serialize: _wellbeingLogModelSerialize,
  deserialize: _wellbeingLogModelDeserialize,
  deserializeProp: _wellbeingLogModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _wellbeingLogModelGetId,
  getLinks: _wellbeingLogModelGetLinks,
  attach: _wellbeingLogModelAttach,
  version: '3.1.0+1',
);

int _wellbeingLogModelEstimateSize(
  WellbeingLogModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _wellbeingLogModelSerialize(
  WellbeingLogModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeLong(offsets[1], object.moodRating);
  writer.writeDouble(offsets[2], object.sleepDurationHours);
  writer.writeDouble(offsets[3], object.waterIntakeLiters);
}

WellbeingLogModel _wellbeingLogModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WellbeingLogModel();
  object.date = reader.readDateTime(offsets[0]);
  object.id = id;
  object.moodRating = reader.readLong(offsets[1]);
  object.sleepDurationHours = reader.readDouble(offsets[2]);
  object.waterIntakeLiters = reader.readDouble(offsets[3]);
  return object;
}

P _wellbeingLogModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _wellbeingLogModelGetId(WellbeingLogModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _wellbeingLogModelGetLinks(
    WellbeingLogModel object) {
  return [];
}

void _wellbeingLogModelAttach(
    IsarCollection<dynamic> col, Id id, WellbeingLogModel object) {
  object.id = id;
}

extension WellbeingLogModelQueryWhereSort
    on QueryBuilder<WellbeingLogModel, WellbeingLogModel, QWhere> {
  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension WellbeingLogModelQueryWhere
    on QueryBuilder<WellbeingLogModel, WellbeingLogModel, QWhereClause> {
  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterWhereClause>
      dateEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterWhereClause>
      dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterWhereClause>
      dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterWhereClause>
      dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterWhereClause>
      dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WellbeingLogModelQueryFilter
    on QueryBuilder<WellbeingLogModel, WellbeingLogModel, QFilterCondition> {
  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
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

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      moodRatingEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moodRating',
        value: value,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      moodRatingGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'moodRating',
        value: value,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      moodRatingLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'moodRating',
        value: value,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      moodRatingBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'moodRating',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      sleepDurationHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepDurationHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      sleepDurationHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepDurationHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      sleepDurationHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepDurationHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      sleepDurationHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepDurationHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      waterIntakeLitersEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waterIntakeLiters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      waterIntakeLitersGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'waterIntakeLiters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      waterIntakeLitersLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'waterIntakeLiters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterFilterCondition>
      waterIntakeLitersBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'waterIntakeLiters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension WellbeingLogModelQueryObject
    on QueryBuilder<WellbeingLogModel, WellbeingLogModel, QFilterCondition> {}

extension WellbeingLogModelQueryLinks
    on QueryBuilder<WellbeingLogModel, WellbeingLogModel, QFilterCondition> {}

extension WellbeingLogModelQuerySortBy
    on QueryBuilder<WellbeingLogModel, WellbeingLogModel, QSortBy> {
  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      sortByMoodRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moodRating', Sort.asc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      sortByMoodRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moodRating', Sort.desc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      sortBySleepDurationHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepDurationHours', Sort.asc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      sortBySleepDurationHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepDurationHours', Sort.desc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      sortByWaterIntakeLiters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterIntakeLiters', Sort.asc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      sortByWaterIntakeLitersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterIntakeLiters', Sort.desc);
    });
  }
}

extension WellbeingLogModelQuerySortThenBy
    on QueryBuilder<WellbeingLogModel, WellbeingLogModel, QSortThenBy> {
  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      thenByMoodRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moodRating', Sort.asc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      thenByMoodRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moodRating', Sort.desc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      thenBySleepDurationHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepDurationHours', Sort.asc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      thenBySleepDurationHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepDurationHours', Sort.desc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      thenByWaterIntakeLiters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterIntakeLiters', Sort.asc);
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QAfterSortBy>
      thenByWaterIntakeLitersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterIntakeLiters', Sort.desc);
    });
  }
}

extension WellbeingLogModelQueryWhereDistinct
    on QueryBuilder<WellbeingLogModel, WellbeingLogModel, QDistinct> {
  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QDistinct>
      distinctByMoodRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moodRating');
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QDistinct>
      distinctBySleepDurationHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepDurationHours');
    });
  }

  QueryBuilder<WellbeingLogModel, WellbeingLogModel, QDistinct>
      distinctByWaterIntakeLiters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'waterIntakeLiters');
    });
  }
}

extension WellbeingLogModelQueryProperty
    on QueryBuilder<WellbeingLogModel, WellbeingLogModel, QQueryProperty> {
  QueryBuilder<WellbeingLogModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WellbeingLogModel, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<WellbeingLogModel, int, QQueryOperations> moodRatingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moodRating');
    });
  }

  QueryBuilder<WellbeingLogModel, double, QQueryOperations>
      sleepDurationHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepDurationHours');
    });
  }

  QueryBuilder<WellbeingLogModel, double, QQueryOperations>
      waterIntakeLitersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waterIntakeLiters');
    });
  }
}
