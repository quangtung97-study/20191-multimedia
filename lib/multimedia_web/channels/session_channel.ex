defmodule MultimediaWeb.SessionChannel do
  use MultimediaWeb, :channel

  def join("session:" <> session_id, _payload, socket) do
    signed_session_id = socket.assigns[:session_id]
    {session_id, _} = Integer.parse(session_id)

    if session_id == signed_session_id do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end
end
