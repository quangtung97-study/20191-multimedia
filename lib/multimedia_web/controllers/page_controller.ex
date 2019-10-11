defmodule MultimediaWeb.PageController do
  use MultimediaWeb, :controller

  alias Multimedia.{User, UserSession, Repo}

  def index(conn, _params) do
    case conn.assigns[:session] do
      nil ->
        redirect(conn, to: "/login")

      session ->
        csrf_token = get_csrf_token()
        conn
        |> render("home.html", csrf_token: csrf_token)
    end
  end

  def login(conn, _params) do
    changeset = User.login_changeset(%{})
    render(conn, "login.html", changeset: changeset)
  end

  defp check_login(email, password) do
    user = Repo.get_by(User, email: email)

    if user do
      if Bcrypt.verify_pass(password, user.password_hash) == true do
        {:ok, user}
      else
        changeset = User.login_changeset(%{email: email, password: password})
        {:error, :password_incorrect, changeset}
      end
    else
      changeset = User.login_changeset(%{email: email, password: password})
      {:error, :user_not_exist, changeset}
    end
  end

  def login_post(conn, %{"user" => %{"email" => email, "password" => password}}) do
    with {:ok, user} <- check_login(email, password) do
      changeset = UserSession.changeset(%UserSession{}, %{user_id: user.id, browser: "Chrome"})
      session = Repo.insert!(changeset)
      IO.inspect(session)

      conn
      |> put_session(:session_id, session.id)
      |> redirect(to: Routes.page_path(conn, :index))
    else
      {:error, :password_incorrect, changeset} ->
        conn
        |> put_flash(:error, "Password is incorrect")
        |> render("login.html", changeset: changeset)

      {:error, :user_not_exist, changeset} ->
        conn
        |> put_flash(:error, "Email is not exist")
        |> render("login.html", changeset: changeset)
    end
  end

  def register(conn, _params) do
    live_render(conn, MultimediaWeb.RegisterLive, session: %{})
  end

  def logout(conn, _params) do
    session = conn.assigns[:session]
    Repo.delete!(session)

    conn
    |> clear_session()
    |> redirect(to: "/login")
  end
end
