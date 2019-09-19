defmodule MultimediaWeb.AuthPlug do
  import Plug.Conn
  import Ecto.Query

  alias Multimedia.{UserSession, User, Repo}

  def init(params), do: params

  @spec get_user(UserSession.t()) :: nil | User.t()
  defp get_user(session) do
    query =
      from u in User,
        where: u.id == ^session.user_id

    Repo.one(query)
  end

  def call(%Plug.Conn{} = conn, _params) do
    with session_id when not is_nil(session_id) <- get_session(conn, :session_id),
         session when not is_nil(session) <- Repo.get(UserSession, session_id),
         user when not is_nil(user) <- get_user(session) do
      conn
      |> assign(:session, session)
      |> assign(:user, user)
    else
      _ -> conn
    end
  end
end
