class MovieModel {
  final int id;
  final String title;
  final String? posterPath;
  String? localImagePath;
  final String? overview;
  final String? releaseDate;
  final double? voteAverage;
  final int? runtime;
  final int? revenue;

  MovieModel({
    required this.id,
    required this.title,
    this.posterPath,
    this.localImagePath,
    this.overview,
    this.releaseDate,
    this.voteAverage,
    this.runtime,
    this.revenue,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) => MovieModel(
    id: json['id'],
    title: json['title'],
    posterPath: json['poster_path'],
    overview: json['overview'],
    releaseDate: json['release_date'],
    voteAverage: json['vote_average'] != null
        ? (json['vote_average'] as num).toDouble()
        : null,
    runtime: json['runtime'],
    revenue: json['revenue'],
  );
}

class MovieDetailModel extends MovieModel {
  MovieDetailModel({
    required int id,
    required String title,
    String? posterPath,
    String? localImagePath,
    String? overview,
    String? releaseDate,
    double? voteAverage,
    int? runtime,
    int? revenue,
  }) : super(
    id: id,
    title: title,
    posterPath: posterPath,
    localImagePath: localImagePath,
    overview: overview,
    releaseDate: releaseDate,
    voteAverage: voteAverage,
    runtime: runtime,
    revenue: revenue,
  );

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) =>
      MovieDetailModel(
        id: json['id'],
        title: json['title'],
        posterPath: json['poster_path'],
        overview: json['overview'],
        releaseDate: json['release_date'],
        voteAverage: json['vote_average'] != null
            ? (json['vote_average'] as num).toDouble()
            : null,
        runtime: json['runtime'],
        revenue: json['revenue'],
      );
}
