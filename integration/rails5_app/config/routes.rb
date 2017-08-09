Rails.application.routes.draw do
  root 'test#index'

  get '/test_debugger', to: 'test#test_debugger'
  get '/test_debugger_info', to: 'test#test_debugger_info'
  get '/test_error_reporting', to: 'test#test_error_reporting'
  get '/test_logging', to: 'test#test_logging'
  get '/test_logger', to: 'test#test_logger'
end
