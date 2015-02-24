require_relative 'spec_helper.rb'

describe 'Services' do
  describe '::Connection' do
    it 'should setup' do
      Services::Connection.new host: 'localhost'
    end

    it 'should fail without something to connect too' do
      expect { Services::Connection.new }.to raise_error
    end

    # chef functions in chef-spec specs ?
    # it "should accept a chef run_context" do
    #  Services::Connection.new(
    #    run_context: Chef::RunContext.new(
    #      Chef::Node.new,
    #      Chef::CookbookCollection.new,
    #      Chef::EventDispatch::Dispatcher.new
    #    )
    #  )
    # end
  end

  before(:each) do
    Services::Connection.new host: 'localhost'
  end

  it 'can set' do
    s = Services.set('/test/1', value: 1)
    s.node.key.should eql '/test/1'
    s.node.value.should eql '1'
  end

  it 'can get' do
    Services.get('/test/1').value.should eql '1'
  end

  it 'handles unknown keys on get' do
    Services.get('/BLARGH!@#@!').should eql nil
  end

  it 'gets all services' do
    a = Services.all
    a.count.should eql 2
    a[0].members.map(&:name).sort.should eql %w(test_member test_member2)
  end

  it 'lists subscribed services' do
    Services.subscribed('test').should eql []
    Services.subscribed('test_member').should eql ['test']
  end

  describe '::Entity' do
    before(:each) do
      Services::Connection.new host: 'localhost'
    end

    it 'should raise when directly instanced' do
      expect { Services::Entity.new('foo') }.to raise_error(RuntimeError)
    end
  end
end
