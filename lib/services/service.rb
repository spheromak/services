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
      Services.set "#{KEY}/#{name}/_created",
                   value: Time.now unless Services.exists? "#{KEY}/#{name}"
    end

    def load_endpoint
      endpoint.load
      endpoint
    end

    def fetch_members
      Services.get("#{KEY}/#{name}/members").children if Services.exists? "#{KEY}/#{name}/members"
    end

    # rubocop:disable MethodLength
    def load_members
      etcd_members = fetch_members
      etcd_members.each do |m|
        m_name = File.basename m.key
        m1 = Services::Member.new(m_name, service: name)
        m1.load
        @members.push m1
      end unless etcd_members.nil? || etcd_members.empty?
    end
  end
end
