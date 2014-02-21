#
# Services Module
#
#  Uses etcd to manage state of Service Endpoint & Members
#
module Services
  require_relative 'services/version'
  require_relative 'services/connection'
  require_relative 'services/entity'
  require_relative 'services/service'
  require_relative 'services/endpoint'
  require_relative 'services/member'

  # this will  change or be slurped up from a config/node attrib
  KEY = '/services'

  #
  # Share a connection between all classess using this module
  #
  class << self
    attr_accessor :connection, :run_context

    # proxy method to Etcd::Client.get
    def get(*args)
      Chef::Log.debug "connection.get args #{args}" unless run_context.nil?
      connection.get(*args) if exists?(*args)
    end

    # proxy method to Etcd::Client.set
    def set(*args)
      Chef::Log.debug "connection.set args #{args}" unless run_context.nil?
      connection.set(*args)
    end

    # proxy method to Etcd::Client.exists?
    def exists?(*args)
      connection.exists?(*args)
    end

    # return a list of all services
    def all
      services = []
      get(KEY).node.children.each do |s|
        name = File.basename s.key
        services << Services::Service.new(name)
      end
      services
    end

    # return all services a node is subscribed to
    def subscribed(f = nil)
      fail 'param and run_context can not both be nil' if f.nil? && run_context.nil?
      fqdn = f.nil? ? run_context.node.fqdn : f
      services = []
      all.each do |s|
        services.concat s.members.map { |m| m.name == fqdn ? s.name : nil }
      end
      services.compact
    end
  end
end
