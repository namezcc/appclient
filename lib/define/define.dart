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

enum NetCMMsgId {
  login,
  ping,
  taskChat,
  loadTaskChat,
  chatRead,
}

enum NetSmMsgId {
  none,
  pong,
  errCode,
  chatUpdate,
  chatIndex,
  chatRead,
  end,
}

enum ChatContentType {
  none,
  text,
  image,
}

enum FinishState {
  none,
  haveMoney,
  getMoney,
  down,
}

enum TaskState {
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