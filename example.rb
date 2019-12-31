$LOAD_PATH.unshift( File.expand_path( "../lib", __FILE__ ) )
$LOAD_PATH.unshift( File.expand_path( "../example_protos", __FILE__ ) )
require "async/grpc"
require "hello_service_def"
class MyService < Helloworld::GreeterService
  def say_hello(req, metadata)
    Helloworld::HelloReply.new( message: "Hello #{req.name}" )
  end
end
server = Async::GRPC::Server.new()
server.handle(MyService)
server.start