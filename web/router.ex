defmodule Money.Router do
  use Money.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Money.Auth, repo: Money.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Money do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:index, :show, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/accounts", AccountController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Money do
  #   pipe_through :api
  # end
end
