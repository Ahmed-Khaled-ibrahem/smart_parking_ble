enum FileType {
  image('images'),
  profile('profile'),
  video('videos'),
  audio('audio'),
  document('documents'),
  archive('archives');

  final String folder;

  const FileType(this.folder);
}


class StorageResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  StorageResult.success(this.data) : error = null, isSuccess = true;

  StorageResult.failure(this.error) : data = null, isSuccess = false;
}
