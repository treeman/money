defmodule Money.Router do
  use Money.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Money.Auth, repo: Money.Repo
    plug :preload_user_data, repo: Money.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash # FIXME temp, not needed
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Money.Auth, repo: Money.Repo
    plug :preload_user_data, repo: Money.Repo
  end

  scope "/", Money do
    pipe_through :browser

    get "/", PageController, :index
    resources "/users", UserController, only: [:index, :show, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  scope "/", Money do
    pipe_through [:browser, :authenticate_user]

    resources "/accounts", AccountController
    resources "/transactions", TransactionController, except: [:index]
    get "/budget", BudgetController, :index
    get "/budget/:year/:month", BudgetController, :show

    get "/accounts/:account_id/import", ImportController, :new
    post "/accounts/:account_id/import", ImportController, :parse
  end

  # TODO post transaction and get html formated return.
  # Use another controller or the same? It's not possible to use the same?
  scope "/api/v1", Money do
    pipe_through [:api, :authenticate_user]

    delete "/accounts/:id/transactions", AccountController, :delete_transactions

    resources "/transactions", ApiTransactionController, only: [:create, :update, :delete]
    resources "/categories", CategoryController, only: [:create, :update, :delete]
    resources "/categories_groups", CategoryGroupController, only: [:create, :update, :delete]
  end
end

