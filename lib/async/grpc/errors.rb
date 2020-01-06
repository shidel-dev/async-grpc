require_relative "status_codes"

module Async
  module GRPC
    # BadStatus is an exception class that indicates that an error occurred at
    # either end of a GRPC connection.  When raised, it indicates that a status
    # error should be returned to the other end of a GRPC connection; when
    # caught it means that this end received a status error.
    #
    # There is also subclass of BadStatus in this module for each GRPC status.
    # E.g., the GRPC::Cancelled class corresponds to status CANCELLED.
    #
    # See
    # https://github.com/grpc/grpc/blob/master/include/grpc/impl/codegen/status.h
    # for detailed descriptions of each status code.
    class BadStatus < StandardError
      attr_reader :code, :details, :metadata
  
      # @param code [Numeric] the status code
      # @param details [String] the details of the exception
      # @param metadata [Hash] the error's metadata
      def initialize(code, details = 'unknown cause', metadata = {})
        super("#{code}:#{details}")
        @code = code
        @details = details
        @metadata = metadata
      end
    end
  
    # GRPC status code corresponding to status OK
    class Ok < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::OK, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status CANCELLED
    class Cancelled < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::CANCELLED, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status UNKNOWN
    class Unknown < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::UNKNOWN, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status INVALID_ARGUMENT
    class InvalidArgument < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::INVALID_ARGUMENT, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status DEADLINE_EXCEEDED
    class DeadlineExceeded < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::DEADLINE_EXCEEDED, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status NOT_FOUND
    class NotFound < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::NOT_FOUND, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status ALREADY_EXISTS
    class AlreadyExists < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::ALREADY_EXISTS, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status PERMISSION_DENIED
    class PermissionDenied < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::PERMISSION_DENIED, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status UNAUTHENTICATED
    class Unauthenticated < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::UNAUTHENTICATED, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status RESOURCE_EXHAUSTED
    class ResourceExhausted < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::RESOURCE_EXHAUSTED, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status FAILED_PRECONDITION
    class FailedPrecondition < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::FAILED_PRECONDITION, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status ABORTED
    class Aborted < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::ABORTED, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status OUT_OF_RANGE
    class OutOfRange < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::OUT_OF_RANGE, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status UNIMPLEMENTED
    class Unimplemented < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::UNIMPLEMENTED, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status INTERNAL
    class Internal < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::INTERNAL, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status UNAVAILABLE
    class Unavailable < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::UNAVAILABLE, details, metadata)
      end
    end
  
    # GRPC status code corresponding to status DATA_LOSS
    class DataLoss < BadStatus
      def initialize(details = 'unknown cause', metadata = {})
        super(Async::GRPC::StatusCodes::DATA_LOSS, details, metadata)
      end
    end
  end
end