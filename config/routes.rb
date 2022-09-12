Rails.application.routes.draw do
  get "/by_postcodes", to: "by_postcodes#index"
  get "/by_postcodes/result", to: "by_postcodes#result"
  get "/by_stop", to: "by_stop#index"
  get "/by_stop/result", to: "by_stop#result"
  get "/find_naptanid", to: "find_naptanid#index"
  get "/find_naptanid/result", to: "find_naptanid#result"

  get "/index", to: "index#index"
  root "index#index"
end
