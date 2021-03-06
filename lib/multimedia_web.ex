defmodule MultimediaWeb do
  @moduledoc """
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: MultimediaWeb

      import Plug.Conn
      import MultimediaWeb.Gettext
      alias MultimediaWeb.Router.Helpers, as: Routes

      import Phoenix.LiveView.Controller, only: [live_render: 3]
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/multimedia_web/templates",
        namespace: MultimediaWeb

      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      use Phoenix.HTML

      import MultimediaWeb.ErrorHelpers
      import MultimediaWeb.Gettext
      alias MultimediaWeb.Router.Helpers, as: Routes

      import Phoenix.LiveView,
        only: [live_render: 2, live_render: 3, live_link: 1, live_link: 2]
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller

      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import MultimediaWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
