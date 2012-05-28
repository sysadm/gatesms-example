SmsExample::Application.routes.draw do
  post "sms/update_status" => "sms#update_status"
  get "sms/:id/send_message" => "sms#send_message", :as => :send_message
  get "sms/:id/request_status" => "sms#request_status", :as => :request_status
  resources :sms
  root :to => 'sms#index'
end
