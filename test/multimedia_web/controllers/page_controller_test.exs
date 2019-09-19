defmodule MultimediaWeb.PageControllerTest do
  use MultimediaWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert redirected_to(conn, 302) =~ "/login"
  end
end
