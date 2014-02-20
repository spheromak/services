require 'simplecov'
SimpleCov.start
require_relative '../lib/services.rb'

require 'uuid'
require 'etcd'
# thanks @ranjib for this handy helper
module Etcd
  # helpers to start an etcd cluster
  # rubocop:disable ClassVars
  module SpecHelper
    @@pids =  []

    def self.etcd_binary
      if File.exists? './etcd/etcd'
        './etcd/etcd'
      elsif !!ENV['ETCD_BIN']
        ENV['ETCD_BIN']
      elsif File.exists? '/usr/local/bin/etcd'
        '/usr/local/bin/etcd'
      else
        fail 'etcd binary not found., you need to set ETCD_BIN'
      end
    end

    def self.start_etcd_servers
      @@tmpdir = Dir.mktmpdir
      pid = spawn_etcd_server(@@tmpdir + '/leader')
      @@pids =  Array(pid)
      leader = '127.0.0.1:7001'
      4.times do |n|
        client_port = 4002 + n
        server_port = 7002 + n
        pid = spawn_etcd_server(@@tmpdir + client_port.to_s, client_port, server_port, leader)
        @@pids << pid
      end
    end

    def self.stop_etcd_servers
      @@pids.each do |pid|
        Process.kill('TERM', pid)
      end
      FileUtils.remove_entry_secure(@@tmpdir, true)
    end

    def self.spawn_etcd_server(dir, client_port = 4001, server_port = 7001, leader = nil)
      args = " -addr 127.0.0.1:#{client_port} -peer-addr 127.0.0.1:#{server_port} -data-dir #{dir} -name node_#{client_port}"
      command = if leader.nil?
                  etcd_binary + args
                else
                  etcd_binary + args + " -peers #{leader}"
                end
      pid = spawn(command, out: '/dev/null')
      Process.detach(pid)
      sleep 1
      pid
    end

    def uuid
      @uuid ||= UUID.new
    end

    def random_key(n = 1)
      key = ''
      n.times do
        key << '/' + uuid.generate
      end
      key
    end

    def etcd_servers
      (1..5).map { |n| "http://127.0.0.1:700#{n}" }
    end

    def other_client
      Etcd.client
    end

    def read_only_client
      Etcd.client(allow_redirect: false, port: 4004)
    end
  end
end

RSpec.configure do |config|

  config.include Etcd::SpecHelper

  config.before(:suite) do
    Etcd::SpecHelper.start_etcd_servers
  end

  config.after(:suite) do
    Etcd::SpecHelper.stop_etcd_servers
  end
  # Use color in STDOUT
  config.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate
end
