require File.dirname(__FILE__) + '/spec_helper'

class ThingsController < ApplicationController
  def index
    render :text => "This is the response body!"
  end
end

describe ActionController::Caching::MemCachePage do
  before do
    ThingsController.stubs(:perform_caching).returns(true)

    @controller = ThingsController.new
    @controller.stubs(:perform_caching).returns(true)
    @controller.stubs(:caching_allowed).returns(true)

    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  it "should be included in ActionController::Base" do
    ActionController::Base.should include(ActionController::Caching::MemCachePage)
  end
  
  describe "defaults" do
    before { ActionController::Caching::MemCachePage.set_defaults! }
    
    it "should have default cache_store equal to Rails.cache" do
      ActionController::Caching::MemCachePage.cache_store.should == Rails.cache
    end
    
    it "should have default namespace nil" do
      ActionController::Caching::MemCachePage.namespace.should be_nil
    end
    
    it "should have default use_md5 false" do
      ActionController::Caching::MemCachePage.use_md5.should be_false
    end
  end
  
  describe ".configure" do
    before do
      @cache = ActiveSupport::Cache.lookup_store(:memory_store)
      ActionController::Caching::MemCachePage.configure do |config|
        config.cache_store  = @cache
        config.namespace    = "boogers"
        config.use_md5      = true
      end
    end
    
    it "should allow you to set the cache_store" do
      ActionController::Caching::MemCachePage.cache_store.should == @cache
    end
    
    it "should allow you to set the namespace" do
      ActionController::Caching::MemCachePage.namespace.should == "boogers"
    end
    
    it "should allow you to set whether or not to use MD5" do
      ActionController::Caching::MemCachePage.use_md5.should be_true
    end
  end

  describe "#mem_caches_page" do
    before { ActionController::Caching::MemCachePage.set_defaults! }
    
    it "should define an after_filter on the controller" do
      ThingsController.expects(:after_filter)
      ThingsController.mem_caches_page(:index)
    end

    describe "by default" do
      it "should put the response body into the cache with the request URI as the key" do
        ThingsController.mem_caches_page(:index)
        ActionController::Caching::MemCachePage.cache_store.expects(:write).with("/things", "This is the response body!", {}).at_least_once
        get :index
      end
    end
    
    describe "when use_md5 is true" do
      before do
        ActionController::Caching::MemCachePage.configure do |config|
          config.use_md5 = true
        end
      end
      
      it "should put the response body into the cache with an MD5 hash of the request URI as the key" do
        ThingsController.mem_caches_page(:index)
        ActionController::Caching::MemCachePage.cache_store.expects(:write).with(MD5.hexdigest("/things"), "This is the response body!", {}).at_least_once
        get :index
      end
    end
    
    describe "when namespace is set to something" do
      before do
        ActionController::Caching::MemCachePage.configure do |config|
          config.namespace = "boogers"
        end      
      end
      
      it "should put the response body into the cache with a key of 'namespace:request URI'" do
        ThingsController.mem_caches_page(:index)
        ActionController::Caching::MemCachePage.cache_store.expects(:write).with("boogers:/things", "This is the response body!", {}).at_least_once
        get :index
      end
    end
    
    describe "when options are passed" do
      it "should send the options to the cache_store" do
        ThingsController.mem_caches_page(:index, :expires_in => 300)
        ActionController::Caching::MemCachePage.cache_store.expects(:write).with("/things", "This is the response body!", { :expires_in => 300 }).at_least_once
        get :index        
      end
    end    
  end
end