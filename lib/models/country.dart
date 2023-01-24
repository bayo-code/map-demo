enum CountryCategory {
  nearMe(0),
  downloaded(1),
  available(2);

  final int id;

  const CountryCategory(this.id);

  static CountryCategory get(int id) {
    return CountryCategory.values.firstWhere((item) => item.id == id);
  }
}

enum CountryStatus {
  unknown(0),
  progress(1),
  applying(2),
  enqueued(3),
  failed(4),
  updatable(5),
  done(6),
  downloadable(7),
  partly(8);

  final int id;

  const CountryStatus(this.id);

  static CountryStatus get(int id) {
    return CountryStatus.values.firstWhere((item) => item.id == id);
  }
}

enum CountryError {
  none(0),
  unknown(1),
  oom(2),
  noInternet(3);

  final int id;

  const CountryError(this.id);

  static CountryError get(int id) {
    return CountryError.values.firstWhere((item) => item.id == id);
  }
}

class Country {
  int? bytesToDownload;
  CountryCategory? category;
  int? childCount;
  String? description;
  String? directParentId;
  String? directParentName;
  int? downloadedBytes;
  int? enqueuedSize;
  CountryError? errorCode;
  int? headerId;
  String? id;
  String? name;
  bool? present;
  int? progress;
  int? size;
  CountryStatus? status;
  int? totalChildCount;
  int? totalSize;

  Country(
      {this.bytesToDownload,
      this.category,
      this.childCount,
      this.description,
      this.directParentId,
      this.directParentName,
      this.downloadedBytes,
      this.enqueuedSize,
      this.errorCode,
      this.headerId,
      this.id,
      this.name,
      this.present,
      this.progress,
      this.size,
      this.status,
      this.totalChildCount,
      this.totalSize});

  Country.fromJson(Map<String, dynamic> json) {
    bytesToDownload = json['bytesToDownload'];
    category = CountryCategory.get(json['category']);
    childCount = json['childCount'];
    description = json['description'];
    directParentId = json['directParentId'];
    directParentName = json['directParentName'];
    downloadedBytes = json['downloadedBytes'];
    enqueuedSize = json['enqueuedSize'];
    errorCode = CountryError.get(json['errorCode']);
    headerId = json['headerId'];
    id = json['id'];
    name = json['name'];
    present = json['present'];
    progress = json['progress'];
    size = json['size'];
    status = CountryStatus.get(json['status']);
    totalChildCount = json['totalChildCount'];
    totalSize = json['totalSize'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bytesToDownload'] = bytesToDownload;
    data['category'] = category!.id;
    data['childCount'] = childCount;
    data['description'] = description;
    data['directParentId'] = directParentId;
    data['directParentName'] = directParentName;
    data['downloadedBytes'] = downloadedBytes;
    data['enqueuedSize'] = enqueuedSize;
    data['errorCode'] = errorCode!.id;
    data['headerId'] = headerId;
    data['id'] = id;
    data['name'] = name;
    data['present'] = present;
    data['progress'] = progress;
    data['size'] = size;
    data['status'] = status!.id;
    data['totalChildCount'] = totalChildCount;
    data['totalSize'] = totalSize;
    return data;
  }
}
