defmodule RetroTaxiWeb.BoardController do
  use RetroTaxiWeb, :controller

  import Phoenix.LiveView.Controller

  alias RetroTaxi.BoardCreation
  alias RetroTaxi.BoardCreation.Request, as: BoardCreationRequest
  alias RetroTaxi.Users

  def new(conn, _params) do
    changeset =
      BoardCreation.change_request(
        %BoardCreationRequest{},
        %{
          facilitator_name: user_name_from_session(conn)
        }
      )

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{
        "request" => %{
          "board_name" => board_name,
          "facilitator_name" => facilitator_name
        }
      }) do
    request = %BoardCreationRequest{board_name: board_name, facilitator_name: facilitator_name}

    # TODO: Need to add lookup for user_id
    case BoardCreation.process_request(request, nil) do
      {:ok, board, _user} ->
        redirect(conn, to: Routes.board_path(conn, :show, board.id))

      {:error, :user_not_found} ->
        changeset =
          BoardCreation.change_request(
            %BoardCreationRequest{},
            %{
              board_name: board_name,
              facilitator_name: facilitator_name
            }
          )

        conn
        |> put_flash(:error, "Internal error: Expected to find user but none found.")
        |> render("new.html", changeset: changeset)

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Could not create board.")
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => board_id}) do
    conn
    |> populate_empty_identity_id()
    |> live_render(RetroTaxiWeb.BoardLive, session: %{"board_id" => board_id})
  end

  defp user_name_from_session(conn) do
    user_name_from_user_id(Plug.Conn.get_session(conn, :user_id))
  end

  defp user_name_from_user_id(nil), do: nil

  defp user_name_from_user_id(user_id) do
    case Users.get_user(user_id) do
      nil -> nil
      user -> user.name
    end
  end

  defp populate_empty_identity_id(conn) do
    if is_nil(Plug.Conn.get_session(conn, :identity_id)) do
      Plug.Conn.put_session(conn, :identity_id, Ecto.UUID.generate())
    else
      conn
    end
  end
end
