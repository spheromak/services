# Services::Endpoint
# The VIP of the service. This class describes where an endpoint lives
#
module Services
  require_relative 'entity'

  # endpoint describes a VIP ip
  class Endpoint < Services::Entity
    attr_accessor :ip, :port, :proto
    def initialize(name, args = {})
      @ip    = args[:ip] || ''
      @proto = args[:proto] || 'http'
      @port  = args[:port]  || 80
      @path  = "#{name}/endpoint"
      super
    end

    private

    def validate
      fail 'endpont requires a service name' unless name
    end
  end
end
