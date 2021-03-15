defmodule RetroTaxiWeb.BoardMockupController do
  use RetroTaxiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
