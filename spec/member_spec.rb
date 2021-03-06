describe 'Services::Member' do
  before(:each) do
    @m_data = { 'ip' => '127.0.0.2', 'proto' => 'http', 'port' => '80', 'weight' => '20', 'service' => 'test', 'name' => 'test_member' }
    Services::Connection.new host: 'localhost'
    @m = Services::Member.new 'test_member', service: 'test', ip: '127.0.0.2', port: 80, weight: 20
    @m2 = Services::Member.new 'test_member2', service: 'test', ip: '127.0.0.3', port: 80, weight: 20
  end

  it 'should raise without a service' do
    expect { Services::Member.new }.to raise_error
  end

  it 'should raise without a service name' do
    expect { Services::Member.new 'test_member' }.to raise_error
  end

  describe '#to_hash' do
    it 'should return each pair of insance vars' do
      @m.to_hash.should == @m_data
    end
  end

  describe '#store' do
    it 'should store' do
      @m.store
      @m2.store
    end
  end

  describe '#load' do
    before do
      @m = Services::Member.new 'test_member', service: 'test'
    end

    it 'should load' do
      @m.load
      @m.to_hash.should == @m_data
    end

  end
end
