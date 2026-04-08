// ignore: avoid_types_as_parameter_names
abstract class Usecases<Type, Params> {
  Future<Type> call(Params params);
}

class NoParams {}