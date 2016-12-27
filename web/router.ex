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
  end

  # TODO post transaction and get html formated return.
  # Use another controller or the same? It's not possible to use the same?
  scope "/api/v1", Money do
    pipe_through [:api, :authenticate_user]

    delete "/accounts/:id/transactions", AccountController, :delete_transactions
    post "/transactions", ApiTransactionController, :create
    #post "/transactions/:id", ApiTransactionController, :update
    #get "/budget", BudgetController, :index
  end
end

