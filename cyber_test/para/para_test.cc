#include "cyber/cyber.h"
#include "cyber/parameter/parameter_client.h"
#include "cyber/parameter/parameter_server.h"

using apollo::cyber::Parameter;
using apollo::cyber::ParameterClient;
using apollo::cyber::ParameterServer;

int main(int argc, char** argv) {
  apollo::cyber::Init(*argv);
  std::shared_ptr<apollo::cyber::Node> node =
      apollo::cyber::CreateNode("parameter");
  auto param_server = std::make_shared<ParameterServer>(node);
  auto param_client = std::make_shared<ParameterClient>(node, "parameter");
  param_server->SetParameter(Parameter("int", 1));
  Parameter parameter;
  param_server->GetParameter("int", &parameter);
  //AINFO << "int: " << parameter.AsInt64();
  T_INFO("#############\n");
  T_INFO("#############\n");
  T_INFO("int:%ld\n", parameter.AsInt64());
  T_INFO("_aa\n");
  param_client->SetParameter(Parameter("string", "test"));
  param_client->GetParameter("string", &parameter);
  //AINFO << "string: " << parameter.AsString();
  T_INFO("string: %s\n",  parameter.AsString().c_str());
  param_client->GetParameter("int", &parameter);
  //AINFO << "int: " << parameter.AsInt64();
  T_INFO("int: %ld\n", parameter.AsInt64());
  T_INFO("#############\n");
  T_INFO("#############\n");
  return 0;
}
