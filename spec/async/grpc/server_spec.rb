require "spec_helper"
require "async/grpc/server"
require "grpc"
require "hello_services_pb"
require "hello_service_def"
require "async/io/notification"
require "securerandom"

RSpec.describe Async::GRPC::Server do
  include_context Async::RSpec::Reactor
  context "E2E Example" do
    let :server_port do
      50027
    end

    let(:endpoint) {Async::HTTP::Endpoint.parse("http://127.0.0.1:#{server_port}", reuse_port: true)}

    class HelloworldTestService < Helloworld::GreeterService
      def say_hello(req, metadata)
        raise "ERROR" if req.name == "ERROR"
        Helloworld::HelloReply.new( message: "Hello #{req.name}" )
      end
    end

    let :hello_world_server do
      server = Async::GRPC::Server.new()
      server.add_http2_port( server_port )
      server.handle( HelloworldTestService )
      server
    end

    let :hello_world_client do
      Helloworld::Greeter::Stub.new( "127.0.0.1:#{server_port}", :this_channel_is_insecure, timeout: 1 )
    end

    it "can answer a helloworld request" do
      notification = Async::IO::Notification.new
      server_task = reactor.async do
        hello_world_server.run( endpoint )
      end

      thd = Thread.new do
        response = nil
        response = make_grpc_request(
          data: {
            name: "grpc"
          },
          proto_file: "hello.proto",
          rpc_path: "helloworld.Greeter/SayHello",
          port: server_port
        )
        expect( response.fetch( "message" ) ).to eq( "Hello grpc" )

        long_randomly_generated_name  = 2000.times.map do |_|
          SecureRandom.uuid
        end.join

        response = make_grpc_request(
          data: {
            name: long_randomly_generated_name
          },
          proto_file: "hello.proto",
          rpc_path: "helloworld.Greeter/SayHello",
          port: server_port
        )
        expect(response.fetch( "message" )).to eq( "Hello #{long_randomly_generated_name}" )
      ensure
        notification.signal
      end
      notification.wait
    ensure
      server_task&.stop
      thd&.join
      notification&.close
    end

    it "can answer a helloworld request with an Error" do
      notification = Async::IO::Notification.new
      server_task = reactor.async do
        hello_world_server.run( endpoint )
      end

      thd = Thread.new do
        response = make_grpc_request(
          data: {
            name: "ERROR"
          },
          proto_file: "hello.proto",
          rpc_path: "helloworld.Greeter/SayHello",
          port: server_port
        )
        expect( response["error"] ).to be
        expect(response.fetch( "error" ).fetch( "code" )).to eq( "Unknown" )
        expect(response.fetch( "error" ).fetch( "message" )).to eq( "Unknown" )
      ensure
        notification.signal
      end
      notification.wait
    ensure
      server_task&.stop
      thd&.join
      notification&.close
    end
  end
end