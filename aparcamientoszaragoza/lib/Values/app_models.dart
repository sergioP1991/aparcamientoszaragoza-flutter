import 'package:aparcamientoszaragoza/Models/comment.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';

class AppModels {
  const AppModels._();

  static List<Garaje> defaultGarajes = [
    Garaje("Garaje 1", "Direccion Garaje 1", 10, 20, 23.4, 34.5, true, false),
    Garaje("Garaje 2", "Direccion Garaje 2", 10, 20, 23.4, 34.5, true, false),
    Garaje("Garaje 3", "Direccion Garaje 3", 10, 20, 23.4, 34.5, true, false),
    Garaje("Garaje 4", "Direccion Garaje 4", 10, 20, 23.4, 34.5, true, true),
    Garaje("Garaje 5", "Direccion Garaje 5", 10, 20, 23.4, 34.5, true, true),
    Garaje("Garaje 6", "Direccion Garaje 5", 10, 20, 23.4, 34.5, true, false),
    Garaje("Garaje 7", "Direccion Garaje 6", 10, 20, 23.4, 34.5, true, true),
    Garaje("Garaje 8", "Direccion Garaje 7", 10, 20, 23.4, 34.5, true, true),
    Garaje("Garaje 9", "Direccion Garaje 8", 10, 20, 23.4, 34.5, true, true),
    Garaje("Garaje 10", "Direccion Garaje 10", 10, 20, 23.4, 34.5, true, true),
    Garaje("Garaje 11", "Direccion Garaje 11", 10, 20, 23.4, 34.5, true, false),
    Garaje("Garaje 12", "Direccion Garaje 12", 10, 20, 23.4, 34.5, true, false),
    Garaje("Garaje 13", "Direccion Garaje 13", 10, 20, 23.4, 34.5, true, true),
    Garaje("Garaje 14", "Direccion Garaje 14", 10, 20, 23.4, 34.5, true, false),
    Garaje("Garaje 15", "Direccion Garaje 15", 10, 20, 23.4, 34.5, true, true),
    Garaje("Garaje 16", "Direccion Garaje 16", 10, 20, 23.4, 34.5, true, false),
    Garaje("Garaje 17", "Direccion Garaje 17", 10, 20, 23.4, 34.5, true, false),
    Garaje("Garaje 18", "Direccion Garaje 18", 10, 20, 23.4, 34.5, true, true),
  ];

  static List<Comment> defaultComments = [
    Comment("1", "123", "Excelente plaza!", "Me encantó la plaza, está muy bien cuidada y tiene mucho espacio para jugar.", DateTime(2024, 07, 04), 5,),
    Comment("2", "456", "Plaza bonita pero ruidosa", "La plaza es bonita, pero está ubicada en una zona muy ruidosa.", DateTime(2024, 07, 03),3),
    Comment("3", "789", "Plaza ideal para familias", "La plaza es ideal para familias, tiene un parque infantil y mucho espacio verde.", DateTime(2024, 07, 02), 4),
    Comment("3", "123", "Excelente plaza!", "Me encantó la plaza, está muy bien cuidada y tiene mucho espacio para jugar.", DateTime(2024, 07, 04), 5,),
    Comment("1", "456", "Plaza bonita pero ruidosa", "La plaza es bonita, pero está ubicada en una zona muy ruidosa.", DateTime(2024, 07, 03),3),
    Comment("2", "789", "Plaza ideal para familias", "La plaza es ideal para familias, tiene un parque infantil y mucho espacio verde.", DateTime(2024, 07, 02), 4),
    Comment("2", "123", "Excelente plaza!", "Me encantó la plaza, está muy bien cuidada y tiene mucho espacio para jugar.", DateTime(2024, 07, 04), 5,),
    Comment("3", "456", "Plaza bonita pero ruidosa", "La plaza es bonita, pero está ubicada en una zona muy ruidosa.", DateTime(2024, 07, 03),3),
    Comment("1", "789", "Plaza ideal para familias", "La plaza es ideal para familias, tiene un parque infantil y mucho espacio verde.", DateTime(2024, 07, 02), 4,
    ),
  ];
}