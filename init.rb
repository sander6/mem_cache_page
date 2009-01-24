require 'mem_cache_page'
ActionController::Base.__send__(:include, ActionController::Caching::MemCachePage)