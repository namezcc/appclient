class TableUtil {
  static const String tabChat = "chat";
  static const String tabReadhistory = "readHistory";

  static const String createChat = """
    CREATE TABLE $tabChat (
      taskid TEXT,
      "index" INTEGER,
      cid INTEGER,
      sendername TEXT,
      sendericon TEXT,
      send_time INTEGER,
      content TEXT,
      content_type INTEGER,
      PRIMARY KEY (taskid, "index")
    )
""";

  static const String createReadHistory = """
    CREATE TABLE IF NOT EXISTS $tabReadhistory (
      taskid TEXT PRIMARY KEY,
      updateTime INTEGER,
      task TEXT
    )
""";
}