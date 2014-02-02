require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../web', __FILE__

describe 'App' do
  describe 'get /' do
    it 'should be success' do
      get '/'
      open('x.html','w'){|f|f.write(last_response.body)}
      last_response.should be_ok
    end
  end

  describe 'post /'
  it 'リダイレクトする' do
    post '/', q: 'unko'
    last_response.should be_redirect
    last_response.location.should == 'http://'+last_request.host+'/unko'
  end
end
