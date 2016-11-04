Rails.application.routes.draw do
  root 'test#index'

  get '/test_error_reporting', to: 'test#test_error_reporting'
  get '/test_logging', to: 'test#test_logging'
end
