enum LoadState {
  none,
  loading,
  noMore,
  error,
}

const taskMoneyTypeReward = 0;
const taskMoneyTypeCost = 1;

const sexWoman = 0;
const sexMan = 1;

const maxInterestTask = 100;

enum NetCMMsgId {
  login,
  ping,
  taskChat,
  loadTaskChat,
  chatRead,
  chatUser,
  chatUserGet,
}

enum NetSmMsgId {
  none,
  pong,
  errCode,
  chatUpdate,
  chatIndex,
  chatRead,
  chatUser,
  chatUserSended,
  end,
}

enum ChatContentType {
  none,
  text,
  image,
  task,
}

enum FinishState {
  none,
  haveMoney,
  getMoney,
  down,
}

enum TaskState {
  incheck,
  active,
  reward,
  over,
  delete,
}

class Pair<T1,T2> {
  T1 value1;
  T2 value2;
  Pair(this.value1,this.value2);
}

typedef IntPair = Pair<int,int>;

enum ReportTaskType {
  fanzui,   //违法犯罪
  seqing,   //色情低俗
  zhapian,  //涉嫌欺诈
  zhengzhi, //政治敏感
  other,    //其他
}

enum ReportUserType {
  fanzui,   //违法犯罪
  seqing,   //色情低俗
  zhapian,  //涉嫌欺诈
  zhengzhi, //政治敏感
  other,    //其他
}

class ReportName {
  static List<String> nameTask = [
    "违法犯罪",
    "色情低俗",
    "涉嫌欺诈",
    "政治敏感",
    "其他",
  ];

  static List<String> nameUser = [
    "违法犯罪",
    "色情低俗",
    "涉嫌欺诈",
    "政治敏感",
    "其他",
  ];
}

class ErrorCode {
  static int errSuccess = 0;
  static int errInBlackList = 7;
}

enum DbUserState {
  loadBlackList,
  loadInterestTask,
}

enum TaskOpenState {
  incheck,
  open,
  finish,
}