require_relative 'entity'

module Services
  # This is a service member usually something that
  # would be sitting behind some VIP
  class Member < Services::Entity
    attr_accessor :ip, :port, :proto, :service, :weight
    def initialize(name, args = {})
      @ip = args[:ip] || ''
      @proto = args[:proto] || 'http'
      @port  = args[:port]  || 80
      @weight = args[:weight] || 20
      @service = args[:service]
      @path = "#{service}/members/#{name}"
      super
    end

    private

    def validate
      unless name && @service
        fail ARgumentError,
             "#{self.class} requires name and service argument"
      end
    end
  end
end
