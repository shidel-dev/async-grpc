require 'async/container'
require 'async/http/endpoint'
require 'async/http/server'
require 'async/io/shared_endpoint'
require 'async/io/ssl_endpoint'
require 'async/io/endpoint'
require "async/io/stream"
require "async/grpc/service"

module Async
  module GRPC
    class Server
      
      def initialize()
        @services = {}
      end

      def handle( service )
        service = service.new
        raise ArgumentError.new( "service must be an instance of Async::GRPC::Service" ) unless service.is_a?( Async::GRPC::Service )
        @services[service.class.service_full_name] = service
      end

      def start
        endpoint = Async::HTTP::Endpoint.parse("http://localhost:4444")
        bound_endpoint = Async::Reactor.run do
          Async::IO::SharedEndpoint.bound(endpoint)
        end.wait

        container_class = Async::Container::Hybrid
        Async.logger.info(endpoint) do |buffer|
          buffer.puts "Starting Grpc"
          buffer.puts "- To terminate: Ctrl-C or kill #{Process.pid}"
        end

        container = container_class.new

        container.attach do
          bound_endpoint.close
        end

        container.run(name: "GRPC Server", restart: false, count: 3) do |task, instance|
          task.async do |connection_task|
            bound_endpoint.accept do |socket|
              begin
                server = Async::HTTP::Protocol::HTTP2.server( socket ).requests.async do |task, request|
                  service_name_full, method = request.path[1..-1].split( "/" )
                  service = @services[service_name_full]
                  rpc = service.class.rpcs[method]
                  body = ""
                  while chunk = request.body.read 
                    body += chunk
                  end

                  _, len, buf = body.unpack("CNa*")
                  request_proto = rpc.fetch( :input_class ).decode( buf )
                  response = service.send( rpc.fetch( :ruby_method ), request_proto, {} )
                  response_proto = response.to_proto
                  buf = [0, response_proto.length, response_proto].pack("CNa*")
                  request.stream.send_headers(nil, [
                    [":status", "200"],
                    ["content-type", "application/grpc"],
                    ["grpc-accept-encoding", "identity,deflate,gzip"],
                    ["accept-encoding", "identity,gzip"],
                  ])
                  data_frame = Protocol::HTTP2::DataFrame.new(request.stream.id)
                  data_frame.pack(buf)
                  request.stream.write_frame(data_frame)
                  request.stream.send_headers(nil, [
                    ["grpc-status", "0"],
                    ["grpc-message", "OK"],
                  ], Protocol::HTTP2::END_STREAM)
                end
              rescue => e
                puts e.inspect
              ensure
                socket&.close
              end
            end
          end
          (task.children || []).each(&:wait)
        end

        container.wait
      end
    end
  end
end
				
