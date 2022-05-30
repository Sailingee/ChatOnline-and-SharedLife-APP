import 'package:danc/MainPage/item/Message.dart';

class MessageCacheQueue{
  //late Queue<Message> queue;
  late List<Message> queue;
  MessageCacheQueue(){
    queue = [];
  }
  final int capacity = 20;
  void add(Message mes){
    if(queue.length>=capacity)
      queue.removeAt(0);
    queue.add(mes);
  }

  Message? cacheMessage = null;
  bool isContains(String ID){
    for(int i=0;i<queue.length;++i){
      if(queue[i].creatorID!+queue[i].messageID.toString() == ID)
        {
          cacheMessage = queue[i];
          return true;
        }
    }
    return false;
  }



}
