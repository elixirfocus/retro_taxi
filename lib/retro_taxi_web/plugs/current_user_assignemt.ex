defmodule RetroTaxiWeb.Plugs.CurrentUserAssignment do
  import Plug.Conn

  alias RetroTaxi.Users

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    assign_current_user(conn, user_id)
  end

  defp assign_current_user(conn, nil) do
    # No user to assign, so just return conn as-is.
    conn
  end

  defp assign_current_user(conn, user_id) do
    case Users.fetch_user(user_id) do
      :user_not_found ->
        conn
        |> send_resp(
          400,
          "User identifier could not be resolved. You may want to clear the browser's cookies for this website and try again."
        )
        |> halt

      {:ok, user} ->
        IO.puts("assigning current user")
        assign(conn, :current_user, user)
    end
  end
end
