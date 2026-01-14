Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"

  # GraphiQL IDE for development
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  # Android usage tracking API
  namespace :api do
    resources :usage, only: [:create, :index] do
      collection do
        get :summary
        get 'today/:package', action: :today, as: :today
      end
    end
  end
end
