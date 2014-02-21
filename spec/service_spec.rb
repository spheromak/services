require_relative 'spec_helper'
describe 'Services::Service' do
  let(:c) { Services::Connection.new host: 'localhost' }
  let(:m1) { Services::Member.new 'test_member', service: 'test', ip: '127.0.0.2', port: 80, weight: 20 }
  let(:m2) { Services::Member.new 'test_member2', service: 'test', ip: '127.0.0.3', port: 80, weight: 20 }

  it 'should load the test service' do
    Services::Connection.new host: 'localhost'
    members = Services::Service.new('test').members
    members.length.should eql 2
    members[0].to_hash.should eql m1.to_hash
    members[1].to_hash.should eql m2.to_hash
  end

  it 'should handle non-existant services' do
    a = Services::Service.new 'should_not_exist'
    a.name.should eql 'should_not_exist'
  end
end
