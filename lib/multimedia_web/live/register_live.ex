defmodule MultimediaWeb.RegisterLive do
  use Phoenix.LiveView

  alias Multimedia.{User, Repo}

  def render(assigns) do
    Phoenix.View.render(MultimediaWeb.PageView, "register.html", assigns)
  end

  def mount(_session, socket) do
    changeset = User.register_changeset(%{})

    socket =
      socket
      |> assign(changeset: changeset)

    {:ok, socket}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset = User.register_changeset(params)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"user" => params}, socket) do
    changeset = User.changeset(%User{}, params)

    case Repo.insert(changeset) do
      {:ok, _} ->
        socket = redirect(socket, to: "/login")
        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end
end
