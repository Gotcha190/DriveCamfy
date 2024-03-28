class SettingsManager {
  static int recordMins = 1;
  static int recordCount = 2; /// 0 , 1, 2 (Three total)

  static void updateSettings(int newRecordMins, int newRecordCount) {
    recordMins = newRecordMins;
    recordCount = newRecordCount;
  }

  // static int get recordMins => _recordMins;
  // static int get recordCount => _recordCount;
}
