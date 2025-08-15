class Pagination {
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasMore;

  Pagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] as int,
      pageSize: json['page_size'] as int,
      totalCount: json['total_count'] as int,
      totalPages: json['total_pages'] as int,
      hasMore: json['has_more'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'page_size': pageSize,
      'total_count': totalCount,
      'total_pages': totalPages,
      'has_more': hasMore,
    };
  }
}