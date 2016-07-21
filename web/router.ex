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
  end
end

