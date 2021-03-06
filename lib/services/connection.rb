module Services
  #
  # Setup ETCD connection via chef or plain host
  # Also stores that aconnection in Services.connection
  # Most other classes require this to be setup
  #
  class Connection
    require 'openssl'

    attr_reader :node, :run_context, :client, :host, :port, :ssl_verify

    if defined?(Chef) == 'constant' && Chef.class == Class
      if Chef::Version.new(Chef::VERSION) <= Chef::Version.new('11.0.0')
        include ::Chef::Mixin::Language
      else
        include ::Chef::DSL::DataQuery
      end
    end

    #
    # Initialize etcd client
    #
    # You should pass either a run_context or explicit host/port arguments
    # the run_context will take prescedence
    #
    # @param [Hash] options
    # @option args [Chef::RunContext] :run_context (nil)
    #   The chef run context to find things in
    # @option args [String] :host (nil) The host address to connect too
    # @option args [String] :port (4001) The etcd port to connect too
    def initialize(args)
      @run_context = args.fetch(:run_context, nil)
      Services.run_context = args[:run_context]
      @node = args[:run_context].node if run_context
      @host = args[:host]
      @port = args[:port] || 4001
      @redirect = args[:redirect] || true
      @ssl_verify = args[:verify] || OpenSSL::SSL::VERIFY_NONE

      validate
      load_gem
      Services.connection = get_connection(find_servers)
    end

    private

    #
    # Validate args passeed in on initialize
    #
    # We require run_context OR host to function
    #
    def validate
      fail ArgumentError, 'Must provide a run_context OR host to initialize' unless
                                                                             run_context || host
    end

    #
    # Lazily Load the gem requirement so we can run inside chef
    #
    # If @run_context exists it will use that to install the gem via
    # Chefs chef_gem resource
    #
    def load_gem
      require 'etcd'
    rescue LoadError
      Chef::Log.info 'etcd gem not found. Please install etcd >= 0.2.0' if run_context
    end

    #
    # Find other Etd Servers by looking at node attributes or via Chef Search
    #
    def find_servers
      # need a run_context to find anything in
      return nil unless run_context
      # If there are already servers in attribs use those
      return node[:etcd][:servers] if node.key?(:etcd) &&
                                      node[:etcd].key?(:servers)

      # if we have already searched in this run use those
      return node.run_state[:etcd_servers] if node.run_state.key? :etcd_servers

      # find nodes and build array of ip's
      etcd_nodes = search(:node, search_query)
      servers = etcd_nodes.map { |n| n[:ipaddress] }

      # store that in the run_state
      node.run_state[:etcd_servers] = servers
    end

    #
    # Setup proper chef search term for other etcd boxen
    #
    # Will search for known recipe in run_list or specified term
    #
    def search_query
      query = "(chef_environment:#{node.chef_environment} "
      query << 'AND recipes:etcd) '
      if node[:etcd][:recipe]
        query << "OR (chef_environment:#{node.chef_environment} "
        query << "AND #{node[:etcd][:search_term]})"
      end
      query
    end

    #
    # connect to ip/port and store in @@client
    # If given an arry of servers then try each until we
    # connect
    # TODO: refactor
    # rubocop:disable MethodLength
    def get_connection(servers = nil)
      c = nil
      if servers
        servers.each do |s|
          c = try_connect(s)
          break if c
        end
      else
        c = try_connect host
      end
      fail 'Unable to get a valid connection to Etcd' unless c
      c
    end

    #
    # Try to grab an etcd connection
    #
    # @param [String] server  ()  The server to try to connect too
    #
    def try_connect(server)
      c = ::Etcd.client(host: server, port: port, allow_redirect: @redirect)
      begin
        c.get '/_etcd/machines'
        return c
      rescue
        puts "ETCD: failed to connect to #{c.host}:#{c.port}"
        return nil
      end
    end
  end
end
