defmodule MultimediaWeb.SessionChannel do
  use MultimediaWeb, :channel
  require Logger

  def join("session:" <> session_id, _payload, socket) do
    signed_session_id = socket.assigns[:session_id]
    {session_id, _} = Integer.parse(session_id)

    if session_id == signed_session_id do
      {:ok, socket}
    else
      {:error, %{reason: "Unauthorized"}}
    end
  end

  def handle_in("test", data, socket) do
    broadcast!(socket, "test", data)
    {:noreply, socket}
  end

  def handle_in("offer", %{"sessionId" => session_id, "data" => offer}, socket) do
    socket.endpoint.broadcast!(
      "session:#{session_id}",
      "requestedConnection",
      %{"sessionId" => socket.assigns[:session_id]}
    )

    socket.endpoint.broadcast!("session:#{session_id}", "remoteOffer", offer)
    {:noreply, socket}
  end

  def handle_in("answer", %{"sessionId" => session_id, "data" => answer}, socket) do
    socket.endpoint.broadcast!("session:#{session_id}", "remoteAnswer", answer)
    {:noreply, socket}
  end

  def handle_in("ice", %{"sessionId" => session_id, "data" => ice}, socket) do
    socket.endpoint.broadcast!("session:#{session_id}", "remoteICE", ice)
    {:noreply, socket}
  end
end
