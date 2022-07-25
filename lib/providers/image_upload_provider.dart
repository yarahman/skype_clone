import 'package:flutter/material.dart';

import '../enums/view_state.dart';

class ImageUploadProvider with ChangeNotifier {
  ViewState viewState = ViewState.idle;

  ViewState get getViewState => viewState;

  void setToLoading() {
    viewState = ViewState.loading;
    notifyListeners();
  }

  void setToIdle() {
    viewState = ViewState.idle;
    notifyListeners();
  }
}
