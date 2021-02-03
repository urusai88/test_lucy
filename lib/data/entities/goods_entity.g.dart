// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goods_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoodsEntity _$GoodsEntityFromJson(Map<String, dynamic> json) {
  return GoodsEntity(
    id: json['id'] as int,
    name: json['name'] as String,
    price: json['price'] as String,
    special: json['special'] as String,
    image: json['image'] as String,
    regularVideo: json['regularVideo'] as String,
    regularVideoPoster: json['regularVideoPoster'] as String,
    sizes: json['sizes'] as String,
  );
}

Map<String, dynamic> _$GoodsEntityToJson(GoodsEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'special': instance.special,
      'image': instance.image,
      'regularVideo': instance.regularVideo,
      'regularVideoPoster': instance.regularVideoPoster,
      'sizes': instance.sizes,
    };
