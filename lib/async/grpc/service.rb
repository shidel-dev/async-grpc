module Async
  module GRPC
    module Service
      module DSL
        def inherited(subclass)
          # Each subclass should have a distinct class variable with its own
          # rpc_descs
          subclass.rpcs.merge!(rpcs)
          subclass.package(package_name)
          subclass.service(service_name)
        end

        # Configure service package name.
        def package(name)
          @package = name.to_s
        end

        # Configure service name.
        def service(name)
          @service = name.to_s
        end

        # Configure service rpc methods.
        def rpc(rpc_method, input_class, output_class, opts)
          raise ArgumentError.new("rpc_method can not be empty") if rpc_method.to_s.empty?
          raise ArgumentError.new("input_class must be a Protobuf Message class") unless input_class.is_a?(Class)
          raise ArgumentError.new("output_class must be a Protobuf Message class") unless output_class.is_a?(Class)
          raise ArgumentError.new("opts[:ruby_method] is mandatory") unless opts && opts[:ruby_method]

          rpcdef = {
            rpc_method: rpc_method.to_sym, # as defined in the Proto file.
            input_class: input_class, # google/protobuf Message class to serialize the input (proto request).
            output_class: output_class, # google/protobuf Message class to serialize the output (proto response).
            ruby_method: opts[:ruby_method].to_sym, # method on the handler or client to handle this rpc requests.
          }

          @rpcs ||= {}
          @rpcs[rpc_method.to_s] = rpcdef

          rpc_define_method(rpcdef) if respond_to? :rpc_define_method # hook for the client to implement the methods on the class
        end

        # Get configured package name as String.
        # An empty value means that there's no package.
        def package_name
          @package.to_s
        end

        # Service name as String. Defaults to the class name.
        def service_name
          (@service || self.name.split("::").last).to_s
        end

        # Service name with package prefix, which should uniquelly identifiy the service,
        # for example "example.v3.Haberdasher" for package "example.v3" and service "Haberdasher".
        # This can be used as a path prefix to route requests to the service, because a Twirp URL is:
        # "#{base_url}/#{service_full_name}/#{method]"
        def service_full_name
          package_name.empty? ? service_name : "#{package_name}.#{service_name}"
        end

        # Get raw definitions for rpc methods.
        # This values are used as base env for handler methods.
        def rpcs
          @rpcs ||= {}
        end
      end

      def self.included(o)
        o.extend(Async::GRPC::Service::DSL)
      end
    end
  end
end