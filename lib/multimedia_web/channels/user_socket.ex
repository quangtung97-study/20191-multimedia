defmodule MultimediaWeb.UserSocket do
  use Phoenix.Socket

  def connect(%{"token" => token}, socket, _connect_info) do
    {:ok, session_id} = Phoenix.Token.verify(socket, "user socket", token, max_age: 86400)
    socket = assign(socket, session_id: session_id)
    {:ok, socket}
  end

  def id(_socket), do: nil

  channel "session:*", MultimediaWeb.SessionChannel
end
