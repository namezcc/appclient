class TableUtil {
  static const String tabChat = "chat";
  static const String tabReadhistory = "readHistory";
  static const String tabChatUser = "chat_user";
  static const String tabChatUserList = "chat_user_list";
  static const String tabBlackList = "black_list";
  static const String tabInterestTask = "interest_task";
  static const String tabUserState = "user_state";

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

  static const String createChatUser = """
    CREATE TABLE IF NOT EXISTS $tabChatUser (
      keycid INTEGER,
      chatid INTEGER,
      cid INTEGER,
      issend INTEGER DEFAULT 0,
      sendername TEXT,
      sendericon TEXT,
      send_time INTEGER,
      content TEXT,
      content_type INTEGER,
      PRIMARY KEY (keycid, chatid)
    )
""";

  static const String createChatUserList = """
    CREATE TABLE IF NOT EXISTS $tabChatUserList (
      keycid INTEGER,
      cid INTEGER,
      read_chat_id INTEGER DEFAULT 0,
      chatid INTEGER,
      sendername TEXT,
      sendericon TEXT,
      send_time INTEGER,
      content TEXT,
      content_type INTEGER,
      PRIMARY KEY (keycid)
    )
""";

  static const String createBlackList = """
    CREATE TABLE IF NOT EXISTS $tabBlackList (
      cid INTEGER,
      PRIMARY KEY (cid)
    )
""";

  static const String createInterestTask = """
    CREATE TABLE IF NOT EXISTS $tabInterestTask (
      taskid TEXT,
      PRIMARY KEY (taskid)
    )
""";

  static const String createUserState = """
    CREATE TABLE IF NOT EXISTS $tabUserState (
      id INTEGER,
      value INTEGER,
      PRIMARY KEY (id)
    )
""";
}