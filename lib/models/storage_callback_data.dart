class StorageCallbackData {
  String? countryId;
  int? newStatus;
  int? errorCode;
  bool? isLeafNode;

  StorageCallbackData(
      {this.countryId, this.newStatus, this.errorCode, this.isLeafNode});

  StorageCallbackData.fromJson(Map<String, dynamic> json) {
    countryId = json['countryId'];
    newStatus = json['newStatus'];
    errorCode = json['errorCode'];
    isLeafNode = json['isLeafNode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['countryId'] = countryId;
    data['newStatus'] = newStatus;
    data['errorCode'] = errorCode;
    data['isLeafNode'] = isLeafNode;
    return data;
  }
}
