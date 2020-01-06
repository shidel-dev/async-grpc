require 'async/container'
require 'async/http/endpoint'
require 'async/http/server'
require 'async/io/shared_endpoint'
require 'async/io/ssl_endpoint'
require 'async/io/endpoint'
require "async/io/stream"
require "async/grpc/service"
require "pry"

module Async
  module GRPC
    class Server
      class InternalError < StandardError
      end

      def initialize(
        interceptors: [],
        concurrency: {
          mode: :threaded, # one of [threaded, hybrid, forked]
          threads: 1,
          forks: nil
        },
        port: "80"
      )
        @endpoint = Async::HTTP::Endpoint.parse("http://0.0.0.0:#{port}")
        @concurrency = concurrency
        @services = {}
      end

      def handle( service )
        service = service.new
        raise ArgumentError.new( "service must be an instance of Async::GRPC::Service" ) unless service.is_a?( Async::GRPC::Service )
        @services[service.class.service_full_name] = service
      end

      def add_http2_port( port )
        @endpoint = Async::HTTP::Endpoint.parse("http://0.0.0.0:#{port}")
      end

      def stop
        @container.stop if @container
      end

      def container_class
        case @concurrency.fetch( :mode, :threaded )
          when :threaded
            Async::Container::Threaded
          when :hybrid
            Async::Container::Hybrid
          when :forked
            Async::Container::Forked
          end
      end

      def run( endpoint )
        accept_task, _ = endpoint.accept do |socket|
          begin
            server = Async::HTTP::Protocol::HTTP2.server( socket ).requests.async do |task, request|
              service_name_full, method = request.path[1..-1].split( "/" )
              service = @services[service_name_full]
              raise StandardError.new( "Service #{service_full_name} Not Found" ) unless service
              rpc = service.class.rpcs[method]
              raise StandardError.new( "Method #{method} Not Found" ) unless rpc
              body = ""
              while chunk = request.body.read 
                body += chunk
              end

              begin
                response_proto = invoke_rpc( rpc, service, body ).to_proto
              rescue => e
                handle_error( e, request.stream )
                next
              end

              buf = [0, response_proto.length, response_proto].pack("CNa*")
              request.stream.send_headers(nil, [
                [":status", "200"],
                ["content-type", "application/grpc"],
                ["grpc-accept-encoding", "identity,deflate,gzip"],
                ["accept-encoding", "identity,gzip"],
              ])
              max_frame_size = request.stream.maximum_frame_size
              io = StringIO.new(buf)
              until io.eof?
                chunk = io.read(max_frame_size)
                data_frame = Protocol::HTTP2::DataFrame.new(request.stream.id)
                data_frame.pack(chunk)
                request.stream.write_frame(data_frame)
              end
              request.stream.send_headers(nil, [
                ["grpc-status", "0"],
                ["grpc-message", "OK"],
              ], Protocol::HTTP2::END_STREAM)
            rescue InternalError => e 
              puts e
              handle_error( err, stream )
            end
          rescue => e
            puts e.inspect
          ensure
            socket&.close
          end
        end
        accept_task.wait
      end

      def start( wait: true )
        bound_endpoint = Async::Reactor.run do
          Async::IO::SharedEndpoint.bound(@endpoint)
        end.wait

        Async.logger.info(@endpoint) do |buffer|
          buffer.puts "Starting GRPC"
          buffer.puts "- To terminate: Ctrl-C or kill #{Process.pid}"
        end

        @container = container_class.new

        @container.attach do
          bound_endpoint.close
        end

        @container.run(name: "GRPC Server", restart: false, count: @concurrency.fetch( :threads )) do |task, instance|
          task.async do |connection_task|
            run( bound_endpoint )
          end
          (task.children || []).each(&:wait)
        end

        if wait
          @container.wait
        else
          @container
        end
      end

      private


      def handle_error( err, stream )
        status = 2
        message = "Unknown"
        if err.is_a? Async::GRPC::BadStatus 
          status = err.code
          message = err.details
        end
        stream.send_headers(nil, [
          [":status", "200"],
          ["content-type", "application/grpc"],
          ["grpc-accept-encoding", "identity,deflate,gzip"],
          ["accept-encoding", "identity,gzip"],
        ])
        stream.send_headers(nil, [
          ["grpc-status", status.to_s],
          ["grpc-message", message],
        ], Protocol::HTTP2::END_STREAM)
      end

      def invoke_rpc( rpc, service, body )
        _, len, buf = body.unpack("CNa*")
        request_proto = rpc.fetch( :input_class ).decode( buf )
        service.send( rpc.fetch( :ruby_method ), request_proto, {} )
      end
    end
  end
end
				
