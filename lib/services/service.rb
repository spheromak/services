# Services::Service
#  this is the almalgamate service class which allows you to load a service
#  and it's endpoint/members
#
# TODO: Allow arbitrary entity loading.
#
module Services
  require_relative 'connection'
  require_relative 'endpoint'
  require_relative 'member'

  # service container
  class Service
    attr_reader :name
    attr_reader :members
    attr_reader :endpoint

    def initialize(name)
      @name = name
      @members = []
      @endpoint = Services::Endpoint.new name

      create_if_missing
      load_members
      load_endpoint
    end

    private

    def create_if_missing
      Services.get "#{KEY}/#{name}"
    rescue Net::HTTPServerException => e
      Services.set "#{KEY}/#{name}/_created", Time.now if e.message.match 'Not Found'
    end

    def load_endpoint
      endpoint.load
      endpoint
    end

    # rubocop:disable MethodLength
    def load_members
      begin
        etcd_members = Services.get "#{KEY}/#{name}/members"
      rescue Net::HTTPServerException => e
        etcd_members = nil if e.message.match 'Not Found'
      end

      unless etcd_members.nil? || etcd_members.empty?
        etcd_members.node.nodes.each do |m|
          m_name = File.basename m['key']
          m1 = Services::Member.new(m_name, service: name)
          m1.load
          @members.push m1
        end
      end
    end
  end
end
