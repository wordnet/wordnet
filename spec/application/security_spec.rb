require 'spec_helper'

require File.expand_path("../../../config/environment", __FILE__)

describe ActiveSupport do
  it 'should use Yajl as default backend' do
    ActiveSupport::JSON.backend.should == MultiJson::Adapters::Yajl
  end
end
