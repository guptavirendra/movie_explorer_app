import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer_app/core/network/network_info.dart';
import 'package:movie_explorer_app/features/movie/data/datasources/movie_local_datasource.dart';
import 'package:movie_explorer_app/features/movie/data/datasources/movie_remote_data_source.dart';

class MockRemoteDatasource extends Mock implements MovieRemoteDataSource {}

class MockLocalDatasource extends Mock implements MovieLocalDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}
