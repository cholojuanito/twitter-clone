abstract class BaseVM {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoadingState(bool state) {
    this._isLoading = state;
  }
}
