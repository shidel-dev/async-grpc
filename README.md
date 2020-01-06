# async-grpc

An async grpc implementation for ruby. Build on top of [Async](https://github.com/socketry/async), and [google-protobuf](https://rubygems.org/gems/google-protobuf/)


Supports:
- Code Generation
- Request Response RPCs

## Why async?

TLDR; For many workloads it can handle higher concurrency, with lower latency then the reference grpc implimentation for ruby.

[The reference implimentation of grpc for ruby](https://github.com/grpc/grpc/tree/master/src/ruby) is built on top of a c++ server implimentation, with c shims, and a ruby wrapper. It has a concurrency model that does not suit low lantancy responses when there are concurrent requests. The reason for this is due to the fact that it uses a bounded thread pool to execute application code. While this might work for some use cases it is limiting due the [GIL](https://en.wikipedia.org/wiki/Global_interpreter_lock), and switching/memory overhead of threads. [Reference](https://www.codeotaku.com/journal/2018-11/fibers-are-the-right-solution/index).

## How do I use it?
For users of the reference implimentation it should be a drop in replacement (TODO: fix some things that make this statement not true).

### Installation
add the following line to you gem file
```ruby
source "https://rubygems.pkg.github.com/shidel-dev" do
  gem "async-grpc", "0.1"
end
```

### Code generation
Requires a working go installation

```
go get github.com/shidel-dev/async-grpc/protoc-gen-async_grpc_ruby
```

Make sure `protoc-gen-async_grpc_ruby` is in your path

```
protoc --proto_path=. --ruby_out=lib --async_grpc_ruby_out=lib my_service.proto
```

### Start a server
```ruby
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
```
