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
    get "/budget", BudgetController, :index
    get "/budget/:year/:month", BudgetController, :show

    get "/accounts/:account_id/import", ImportController, :new
    post "/accounts/:account_id/import", ImportController, :parse
  end

  # TODO post transaction and get html formated return.
  # Use another controller or the same? It's not possible to use the same?
  scope "/api/v1", Money do
    pipe_through [:api, :authenticate_user]

    resources "/transactions", TransactionController, only: [:create, :update, :delete]
    delete "/transactions", TransactionController, :delete_transactions
    delete "/accounts/:id/transactions", AccountController, :delete_transactions

    resources "/categories", CategoryController, only: [:create, :update]
    delete "/categories", CategoryController, :delete_categories

    resources "/category_groups", CategoryGroupController, only: [:create, :update]

    resources "/budgeted_categories", BudgetedCategoryController, only: [:create]
    post "/budgeted_categories/:year/:month", BudgetedCategoryController, :create
    patch "/budgeted_categories/:year/:month", BudgetedCategoryController, :save
    put "/budgeted_categories/:year/:month", BudgetedCategoryController, :save
  end
end

