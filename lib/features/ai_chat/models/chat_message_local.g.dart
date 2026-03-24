// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChatMessageLocalCollection on Isar {
  IsarCollection<ChatMessageLocal> get chatMessageLocals => this.collection();
}

const ChatMessageLocalSchema = CollectionSchema(
  name: r'ChatMessageLocal',
  id: -4440843367276775238,
  properties: {
    r'actionJson': PropertySchema(
      id: 0,
      name: r'actionJson',
      type: IsarType.string,
    ),
    r'actionResultJson': PropertySchema(
      id: 1,
      name: r'actionResultJson',
      type: IsarType.string,
    ),
    r'codeBlock': PropertySchema(
      id: 2,
      name: r'codeBlock',
      type: IsarType.string,
    ),
    r'codeLanguage': PropertySchema(
      id: 3,
      name: r'codeLanguage',
      type: IsarType.string,
    ),
    r'content': PropertySchema(
      id: 4,
      name: r'content',
      type: IsarType.string,
    ),
    r'contentType': PropertySchema(
      id: 5,
      name: r'contentType',
      type: IsarType.string,
    ),
    r'formattedContent': PropertySchema(
      id: 6,
      name: r'formattedContent',
      type: IsarType.string,
    ),
    r'knowledgeCardJson': PropertySchema(
      id: 7,
      name: r'knowledgeCardJson',
      type: IsarType.string,
    ),
    r'quickRepliesJson': PropertySchema(
      id: 8,
      name: r'quickRepliesJson',
      type: IsarType.string,
    ),
    r'reasoningDetailsJson': PropertySchema(
      id: 9,
      name: r'reasoningDetailsJson',
      type: IsarType.string,
    ),
    r'role': PropertySchema(
      id: 10,
      name: r'role',
      type: IsarType.string,
    ),
    r'sessionId': PropertySchema(
      id: 11,
      name: r'sessionId',
      type: IsarType.long,
    ),
    r'timestamp': PropertySchema(
      id: 12,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'translationPairJson': PropertySchema(
      id: 13,
      name: r'translationPairJson',
      type: IsarType.string,
    )
  },
  estimateSize: _chatMessageLocalEstimateSize,
  serialize: _chatMessageLocalSerialize,
  deserialize: _chatMessageLocalDeserialize,
  deserializeProp: _chatMessageLocalDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _chatMessageLocalGetId,
  getLinks: _chatMessageLocalGetLinks,
  attach: _chatMessageLocalAttach,
  version: '3.1.0+1',
);

int _chatMessageLocalEstimateSize(
  ChatMessageLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.actionJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.actionResultJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.codeBlock;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.codeLanguage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.content.length * 3;
  {
    final value = object.contentType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.formattedContent;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.knowledgeCardJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.quickRepliesJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reasoningDetailsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.role.length * 3;
  {
    final value = object.translationPairJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _chatMessageLocalSerialize(
  ChatMessageLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actionJson);
  writer.writeString(offsets[1], object.actionResultJson);
  writer.writeString(offsets[2], object.codeBlock);
  writer.writeString(offsets[3], object.codeLanguage);
  writer.writeString(offsets[4], object.content);
  writer.writeString(offsets[5], object.contentType);
  writer.writeString(offsets[6], object.formattedContent);
  writer.writeString(offsets[7], object.knowledgeCardJson);
  writer.writeString(offsets[8], object.quickRepliesJson);
  writer.writeString(offsets[9], object.reasoningDetailsJson);
  writer.writeString(offsets[10], object.role);
  writer.writeLong(offsets[11], object.sessionId);
  writer.writeDateTime(offsets[12], object.timestamp);
  writer.writeString(offsets[13], object.translationPairJson);
}

ChatMessageLocal _chatMessageLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChatMessageLocal();
  object.actionJson = reader.readStringOrNull(offsets[0]);
  object.actionResultJson = reader.readStringOrNull(offsets[1]);
  object.codeBlock = reader.readStringOrNull(offsets[2]);
  object.codeLanguage = reader.readStringOrNull(offsets[3]);
  object.content = reader.readString(offsets[4]);
  object.contentType = reader.readStringOrNull(offsets[5]);
  object.formattedContent = reader.readStringOrNull(offsets[6]);
  object.id = id;
  object.knowledgeCardJson = reader.readStringOrNull(offsets[7]);
  object.quickRepliesJson = reader.readStringOrNull(offsets[8]);
  object.reasoningDetailsJson = reader.readStringOrNull(offsets[9]);
  object.role = reader.readString(offsets[10]);
  object.sessionId = reader.readLong(offsets[11]);
  object.timestamp = reader.readDateTime(offsets[12]);
  object.translationPairJson = reader.readStringOrNull(offsets[13]);
  return object;
}

P _chatMessageLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _chatMessageLocalGetId(ChatMessageLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _chatMessageLocalGetLinks(ChatMessageLocal object) {
  return [];
}

void _chatMessageLocalAttach(
    IsarCollection<dynamic> col, Id id, ChatMessageLocal object) {
  object.id = id;
}

extension ChatMessageLocalQueryWhereSort
    on QueryBuilder<ChatMessageLocal, ChatMessageLocal, QWhere> {
  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterWhere> anySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sessionId'),
      );
    });
  }
}

extension ChatMessageLocalQueryWhere
    on QueryBuilder<ChatMessageLocal, ChatMessageLocal, QWhereClause> {
  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterWhereClause>
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

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterWhereClause> idBetween(
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

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterWhereClause>
      sessionIdEqualTo(int sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterWhereClause>
      sessionIdNotEqualTo(int sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterWhereClause>
      sessionIdGreaterThan(
    int sessionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId',
        lower: [sessionId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterWhereClause>
      sessionIdLessThan(
    int sessionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId',
        lower: [],
        upper: [sessionId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterWhereClause>
      sessionIdBetween(
    int lowerSessionId,
    int upperSessionId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId',
        lower: [lowerSessionId],
        includeLower: includeLower,
        upper: [upperSessionId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ChatMessageLocalQueryFilter
    on QueryBuilder<ChatMessageLocal, ChatMessageLocal, QFilterCondition> {
  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actionJson',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actionJson',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actionJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actionJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionResultJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actionResultJson',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionResultJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actionResultJson',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionResultJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionResultJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionResultJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionResultJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionResultJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionResultJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionResultJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionResultJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionResultJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actionResultJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionResultJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actionResultJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionResultJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actionResultJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionResultJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actionResultJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionResultJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionResultJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      actionResultJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actionResultJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeBlockIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'codeBlock',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeBlockIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'codeBlock',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeBlockEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codeBlock',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeBlockGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codeBlock',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeBlockLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codeBlock',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeBlockBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codeBlock',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeBlockStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codeBlock',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeBlockEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codeBlock',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeBlockContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codeBlock',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeBlockMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codeBlock',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeBlockIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codeBlock',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeBlockIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codeBlock',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeLanguageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'codeLanguage',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeLanguageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'codeLanguage',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeLanguageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codeLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeLanguageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codeLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeLanguageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codeLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeLanguageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codeLanguage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeLanguageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codeLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeLanguageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codeLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeLanguageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codeLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeLanguageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codeLanguage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeLanguageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codeLanguage',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      codeLanguageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codeLanguage',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contentType',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contentType',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentType',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      contentTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentType',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      formattedContentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'formattedContent',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      formattedContentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'formattedContent',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      formattedContentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      formattedContentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formattedContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      formattedContentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formattedContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      formattedContentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formattedContent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      formattedContentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formattedContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      formattedContentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formattedContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      formattedContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formattedContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      formattedContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formattedContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      formattedContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      formattedContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formattedContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
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

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
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

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
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

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      knowledgeCardJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'knowledgeCardJson',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      knowledgeCardJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'knowledgeCardJson',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      knowledgeCardJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'knowledgeCardJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      knowledgeCardJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'knowledgeCardJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      knowledgeCardJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'knowledgeCardJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      knowledgeCardJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'knowledgeCardJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      knowledgeCardJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'knowledgeCardJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      knowledgeCardJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'knowledgeCardJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      knowledgeCardJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'knowledgeCardJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      knowledgeCardJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'knowledgeCardJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      knowledgeCardJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'knowledgeCardJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      knowledgeCardJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'knowledgeCardJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      quickRepliesJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'quickRepliesJson',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      quickRepliesJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'quickRepliesJson',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      quickRepliesJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quickRepliesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      quickRepliesJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quickRepliesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      quickRepliesJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quickRepliesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      quickRepliesJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quickRepliesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      quickRepliesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'quickRepliesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      quickRepliesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'quickRepliesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      quickRepliesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'quickRepliesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      quickRepliesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'quickRepliesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      quickRepliesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quickRepliesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      quickRepliesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'quickRepliesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      reasoningDetailsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reasoningDetailsJson',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      reasoningDetailsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reasoningDetailsJson',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      reasoningDetailsJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reasoningDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      reasoningDetailsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reasoningDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      reasoningDetailsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reasoningDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      reasoningDetailsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reasoningDetailsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      reasoningDetailsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reasoningDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      reasoningDetailsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reasoningDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      reasoningDetailsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reasoningDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      reasoningDetailsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reasoningDetailsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      reasoningDetailsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reasoningDetailsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      reasoningDetailsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reasoningDetailsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      roleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      roleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      roleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      roleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'role',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      roleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      roleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      roleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      roleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'role',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      roleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      roleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'role',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      sessionIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      sessionIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      sessionIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      sessionIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      translationPairJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'translationPairJson',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      translationPairJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'translationPairJson',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      translationPairJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'translationPairJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      translationPairJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'translationPairJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      translationPairJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'translationPairJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      translationPairJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'translationPairJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      translationPairJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'translationPairJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      translationPairJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'translationPairJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      translationPairJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'translationPairJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      translationPairJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'translationPairJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      translationPairJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'translationPairJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterFilterCondition>
      translationPairJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'translationPairJson',
        value: '',
      ));
    });
  }
}

extension ChatMessageLocalQueryObject
    on QueryBuilder<ChatMessageLocal, ChatMessageLocal, QFilterCondition> {}

extension ChatMessageLocalQueryLinks
    on QueryBuilder<ChatMessageLocal, ChatMessageLocal, QFilterCondition> {}

extension ChatMessageLocalQuerySortBy
    on QueryBuilder<ChatMessageLocal, ChatMessageLocal, QSortBy> {
  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByActionJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionJson', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByActionJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionJson', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByActionResultJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionResultJson', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByActionResultJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionResultJson', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByCodeBlock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codeBlock', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByCodeBlockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codeBlock', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByCodeLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codeLanguage', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByCodeLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codeLanguage', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByContentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByContentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByFormattedContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedContent', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByFormattedContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedContent', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByKnowledgeCardJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knowledgeCardJson', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByKnowledgeCardJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knowledgeCardJson', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByQuickRepliesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quickRepliesJson', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByQuickRepliesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quickRepliesJson', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByReasoningDetailsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reasoningDetailsJson', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByReasoningDetailsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reasoningDetailsJson', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy> sortByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByTranslationPairJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translationPairJson', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      sortByTranslationPairJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translationPairJson', Sort.desc);
    });
  }
}

extension ChatMessageLocalQuerySortThenBy
    on QueryBuilder<ChatMessageLocal, ChatMessageLocal, QSortThenBy> {
  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByActionJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionJson', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByActionJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionJson', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByActionResultJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionResultJson', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByActionResultJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionResultJson', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByCodeBlock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codeBlock', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByCodeBlockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codeBlock', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByCodeLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codeLanguage', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByCodeLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codeLanguage', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByContentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByContentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByFormattedContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedContent', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByFormattedContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedContent', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByKnowledgeCardJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knowledgeCardJson', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByKnowledgeCardJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knowledgeCardJson', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByQuickRepliesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quickRepliesJson', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByQuickRepliesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quickRepliesJson', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByReasoningDetailsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reasoningDetailsJson', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByReasoningDetailsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reasoningDetailsJson', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy> thenByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByTranslationPairJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translationPairJson', Sort.asc);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QAfterSortBy>
      thenByTranslationPairJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translationPairJson', Sort.desc);
    });
  }
}

extension ChatMessageLocalQueryWhereDistinct
    on QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct> {
  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct>
      distinctByActionJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct>
      distinctByActionResultJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionResultJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct>
      distinctByCodeBlock({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codeBlock', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct>
      distinctByCodeLanguage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codeLanguage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct>
      distinctByContentType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct>
      distinctByFormattedContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formattedContent',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct>
      distinctByKnowledgeCardJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'knowledgeCardJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct>
      distinctByQuickRepliesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quickRepliesJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct>
      distinctByReasoningDetailsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reasoningDetailsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct> distinctByRole(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'role', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct>
      distinctBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId');
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<ChatMessageLocal, ChatMessageLocal, QDistinct>
      distinctByTranslationPairJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'translationPairJson',
          caseSensitive: caseSensitive);
    });
  }
}

extension ChatMessageLocalQueryProperty
    on QueryBuilder<ChatMessageLocal, ChatMessageLocal, QQueryProperty> {
  QueryBuilder<ChatMessageLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChatMessageLocal, String?, QQueryOperations>
      actionJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionJson');
    });
  }

  QueryBuilder<ChatMessageLocal, String?, QQueryOperations>
      actionResultJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionResultJson');
    });
  }

  QueryBuilder<ChatMessageLocal, String?, QQueryOperations>
      codeBlockProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codeBlock');
    });
  }

  QueryBuilder<ChatMessageLocal, String?, QQueryOperations>
      codeLanguageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codeLanguage');
    });
  }

  QueryBuilder<ChatMessageLocal, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<ChatMessageLocal, String?, QQueryOperations>
      contentTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentType');
    });
  }

  QueryBuilder<ChatMessageLocal, String?, QQueryOperations>
      formattedContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedContent');
    });
  }

  QueryBuilder<ChatMessageLocal, String?, QQueryOperations>
      knowledgeCardJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'knowledgeCardJson');
    });
  }

  QueryBuilder<ChatMessageLocal, String?, QQueryOperations>
      quickRepliesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quickRepliesJson');
    });
  }

  QueryBuilder<ChatMessageLocal, String?, QQueryOperations>
      reasoningDetailsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reasoningDetailsJson');
    });
  }

  QueryBuilder<ChatMessageLocal, String, QQueryOperations> roleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'role');
    });
  }

  QueryBuilder<ChatMessageLocal, int, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<ChatMessageLocal, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<ChatMessageLocal, String?, QQueryOperations>
      translationPairJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'translationPairJson');
    });
  }
}
