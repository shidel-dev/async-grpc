$LOAD_PATH.unshift( File.expand_path( "../../example_protos", __FILE__ ) )
require 'bundler/setup'
require 'json'
require 'async/rspec'
require 'open3'

module GrpcCurlHelpers
	def make_grpc_request(
		data: ,
		proto_path: File.expand_path( "../../example_protos", __FILE__ ),
		proto_file: ,
		rpc_path:,
		port:
	)
		command = "grpcurl -max-time 5 -d '#{data.to_json}' -plaintext -proto #{File.join( proto_path, proto_file )} 127.0.0.1:#{port} #{rpc_path}"
		stdout, stderr, status = Open3.capture3(command)
		if status.success?
			return JSON.parse(stdout)
		else
			code, message = ["Unknown", "Unknown"]
			unless stderr.empty?
				code, message = stderr.match( /^.*Code:\s*(.*)\s*Message:\s*(.*)/ ).captures
			end

			return {
				"error" => {
					"code" => code,
					"message" => message
				}
			}
		end
  end
end

class DebugFormatter
  RSpec::Core::Formatters.register self, :example_failed

  def initialize(output)
    @output = output
  end

	def example_failed(notification)
		binding.pry
  end
end

RSpec.configure do |config|
	config.include GrpcCurlHelpers
	config.example_status_persistence_file_path = ".rspec_status"
	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end