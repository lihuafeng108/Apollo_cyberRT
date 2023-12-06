
#include "msg/examples.pb.h"

#include "cyber/cyber.h"

using apollo::cyber::examples::proto::Chatter;

void MessageCallback(
    const std::shared_ptr<Chatter>& msg) {
  AINFO << "msgcontent->" << msg->content() <<", Received message seq-> " << msg->seq() << std::endl;
}

int main(int argc, char* argv[]) {
  // init cyber framework
  apollo::cyber::Init(argv[0]);
  // create listener node
  auto listener_node = apollo::cyber::CreateNode("listener");
  // create listener
  auto listener = listener_node->CreateReader<Chatter>("channel/chatter", MessageCallback);
  apollo::cyber::WaitForShutdown();
  return 0;
}