// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGamificationModelCollection on Isar {
  IsarCollection<GamificationModel> get gamificationModels => this.collection();
}

const GamificationModelSchema = CollectionSchema(
  name: r'GamificationModel',
  id: -313084432418505910,
  properties: {
    r'coins': PropertySchema(
      id: 0,
      name: r'coins',
      type: IsarType.long,
    ),
    r'focusStreak': PropertySchema(
      id: 1,
      name: r'focusStreak',
      type: IsarType.long,
    ),
    r'habitStreak': PropertySchema(
      id: 2,
      name: r'habitStreak',
      type: IsarType.long,
    ),
    r'level': PropertySchema(
      id: 3,
      name: r'level',
      type: IsarType.long,
    ),
    r'xp': PropertySchema(
      id: 4,
      name: r'xp',
      type: IsarType.long,
    )
  },
  estimateSize: _gamificationModelEstimateSize,
  serialize: _gamificationModelSerialize,
  deserialize: _gamificationModelDeserialize,
  deserializeProp: _gamificationModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _gamificationModelGetId,
  getLinks: _gamificationModelGetLinks,
  attach: _gamificationModelAttach,
  version: '3.1.0+1',
);

int _gamificationModelEstimateSize(
  GamificationModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _gamificationModelSerialize(
  GamificationModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.coins);
  writer.writeLong(offsets[1], object.focusStreak);
  writer.writeLong(offsets[2], object.habitStreak);
  writer.writeLong(offsets[3], object.level);
  writer.writeLong(offsets[4], object.xp);
}

GamificationModel _gamificationModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GamificationModel();
  object.coins = reader.readLong(offsets[0]);
  object.focusStreak = reader.readLong(offsets[1]);
  object.habitStreak = reader.readLong(offsets[2]);
  object.id = id;
  object.level = reader.readLong(offsets[3]);
  object.xp = reader.readLong(offsets[4]);
  return object;
}

P _gamificationModelDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _gamificationModelGetId(GamificationModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _gamificationModelGetLinks(
    GamificationModel object) {
  return [];
}

void _gamificationModelAttach(
    IsarCollection<dynamic> col, Id id, GamificationModel object) {
  object.id = id;
}

extension GamificationModelQueryWhereSort
    on QueryBuilder<GamificationModel, GamificationModel, QWhere> {
  QueryBuilder<GamificationModel, GamificationModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GamificationModelQueryWhere
    on QueryBuilder<GamificationModel, GamificationModel, QWhereClause> {
  QueryBuilder<GamificationModel, GamificationModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterWhereClause>
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

  QueryBuilder<GamificationModel, GamificationModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterWhereClause>
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
}

extension GamificationModelQueryFilter
    on QueryBuilder<GamificationModel, GamificationModel, QFilterCondition> {
  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      coinsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coins',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      coinsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coins',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      coinsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coins',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      coinsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coins',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      focusStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'focusStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      focusStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'focusStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      focusStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'focusStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      focusStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'focusStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      habitStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'habitStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      habitStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'habitStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      habitStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'habitStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      habitStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'habitStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
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

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
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

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
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

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      levelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      levelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      levelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      levelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'level',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      xpEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xp',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      xpGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xp',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      xpLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xp',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterFilterCondition>
      xpBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension GamificationModelQueryObject
    on QueryBuilder<GamificationModel, GamificationModel, QFilterCondition> {}

extension GamificationModelQueryLinks
    on QueryBuilder<GamificationModel, GamificationModel, QFilterCondition> {}

extension GamificationModelQuerySortBy
    on QueryBuilder<GamificationModel, GamificationModel, QSortBy> {
  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      sortByCoins() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coins', Sort.asc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      sortByCoinsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coins', Sort.desc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      sortByFocusStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusStreak', Sort.asc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      sortByFocusStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusStreak', Sort.desc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      sortByHabitStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitStreak', Sort.asc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      sortByHabitStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitStreak', Sort.desc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      sortByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      sortByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy> sortByXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xp', Sort.asc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      sortByXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xp', Sort.desc);
    });
  }
}

extension GamificationModelQuerySortThenBy
    on QueryBuilder<GamificationModel, GamificationModel, QSortThenBy> {
  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      thenByCoins() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coins', Sort.asc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      thenByCoinsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coins', Sort.desc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      thenByFocusStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusStreak', Sort.asc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      thenByFocusStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusStreak', Sort.desc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      thenByHabitStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitStreak', Sort.asc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      thenByHabitStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitStreak', Sort.desc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      thenByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      thenByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy> thenByXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xp', Sort.asc);
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QAfterSortBy>
      thenByXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xp', Sort.desc);
    });
  }
}

extension GamificationModelQueryWhereDistinct
    on QueryBuilder<GamificationModel, GamificationModel, QDistinct> {
  QueryBuilder<GamificationModel, GamificationModel, QDistinct>
      distinctByCoins() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coins');
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QDistinct>
      distinctByFocusStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'focusStreak');
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QDistinct>
      distinctByHabitStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'habitStreak');
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QDistinct>
      distinctByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'level');
    });
  }

  QueryBuilder<GamificationModel, GamificationModel, QDistinct> distinctByXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xp');
    });
  }
}

extension GamificationModelQueryProperty
    on QueryBuilder<GamificationModel, GamificationModel, QQueryProperty> {
  QueryBuilder<GamificationModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GamificationModel, int, QQueryOperations> coinsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coins');
    });
  }

  QueryBuilder<GamificationModel, int, QQueryOperations> focusStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'focusStreak');
    });
  }

  QueryBuilder<GamificationModel, int, QQueryOperations> habitStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'habitStreak');
    });
  }

  QueryBuilder<GamificationModel, int, QQueryOperations> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'level');
    });
  }

  QueryBuilder<GamificationModel, int, QQueryOperations> xpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xp');
    });
  }
}
