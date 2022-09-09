Rails.application.routes.draw do
  get "/by_postcodes", to: "by_postcodes#index"
  get "/by_postcodes/result", to: "by_postcodes#result"
end
