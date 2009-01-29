require 'md5'
module ActionController
  module Caching
    module MemCachePage
      def self.set_defaults!
        @@cache_store = Rails.cache
        @@namespace   = nil
        @@use_md5     = false
        @@raw         = false
      end
      
      set_defaults!

      def self.cache_store
        @@cache_store
      end
      
      def self.cache_store=(store)
        @@cache_store = store
      end
      
      def self.namespace
        @@namespace
      end
      
      def self.namespace=(namespace)
        @@namespace = namespace
      end
      
      def self.use_md5
        @@use_md5
      end
      
      def self.use_md5=(bool)
        @@use_md5 = bool
      end
      
      def self.raw
        @@raw
      end
      
      def self.raw=(bool)
        @@raw = bool
      end
      
      def self.generate_cache_key(key)
        key = MD5.hexdigest(key) if use_md5
        key = namespace.to_s + ':' + key if namespace
        key
      end
    
      def self.configure
        yield self
      end
  
      def self.included(base)
        base.__send__(:extend, ClassMethods)
        base.__send__(:include, InstanceMethods)
      end
  
      module ClassMethods
        def mem_caches_page(*actions)
          return unless perform_caching
          options = actions.extract_options!
          actions.each { |act| self.write_inheritable_attribute(:"#{act}_cache_options", options) }
          after_filter :mem_cache_page, :only => actions
        end
      end
  
      module InstanceMethods
        def mem_cache_page
          return unless perform_caching && caching_allowed
          cache_key = MemCachePage.generate_cache_key(self.request.request_uri)
          cache_options = self.class.read_inheritable_attribute(:"#{self.params[:action]}_cache_options")
          cache_options.merge(:raw => true) if MemCachePage.raw
          MemCachePage.cache_store.write(cache_key, self.response.body, cache_options)
        end    
      end
    end
  end
end