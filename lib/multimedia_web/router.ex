defmodule MultimediaWeb.Router do
  use MultimediaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug MultimediaWeb.AuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MultimediaWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/login", PageController, :login
    post "/login", PageController, :login_post
    post "/logout", PageController, :logout
    get "/register", PageController, :register
  end

  # scope "/api", MultimediaWeb do
  #   pipe_through :api
  # end
end
