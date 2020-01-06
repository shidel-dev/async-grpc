$LOAD_PATH.unshift( File.expand_path( "../lib", __FILE__ ) )
$LOAD_PATH.unshift( File.expand_path( "../example_protos", __FILE__ ) )
require "async/grpc"
require "hello_service_def"
require "async"
class MyService < Helloworld::GreeterService
  def say_hello(req, metadata)
    task = Async do |task|
      task.sleep 1
    end
    task.wait
    Helloworld::HelloReply.new( message: "Hello #{req.name}" )
  end
end
server = Async::GRPC::Server.new()
server.add_http2_port( 4444 )
server.handle(MyService)
server.start