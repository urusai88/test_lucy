import 'package:json_annotation/json_annotation.dart';

part 'goods_entity.g.dart';

@JsonSerializable()
class GoodsEntity {
  final int id;
  final String name;
  final String price;
  final String special;
  final String image;
  final String regularVideo;
  final String regularVideoPoster;
  final String sizes;

  const GoodsEntity({
    this.id,
    this.name,
    this.price,
    this.special,
    this.image,
    this.regularVideo,
    this.regularVideoPoster,
    this.sizes,
  });

  factory GoodsEntity.fromJson(Map<String, dynamic> json) =>
      _$GoodsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$GoodsEntityToJson(this);
}
