defmodule RetroTaxiWeb.BoardController do
  use RetroTaxiWeb, :controller

  import Phoenix.LiveView.Controller

  alias RetroTaxi.BoardCreation
  alias RetroTaxi.BoardCreation.Request, as: BoardCreationRequest
  alias RetroTaxi.Boards
  alias RetroTaxi.Users
  alias RetroTaxi.Users.User
  alias RetroTaxi.JoinBoard

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
    user_id = Plug.Conn.get_session(conn, :user_id)

    case BoardCreation.process_request(request, user_id) do
      {:ok, board, user} ->
        # update the user_id in the session, since `process_request/2` may have created or updated the user.
        conn
        |> Plug.Conn.put_session(:user_id, user.id)
        |> redirect(to: Routes.board_path(conn, :show, board.id))

      {:error, :user_not_found} ->
        changeset =
          BoardCreation.change_request(%BoardCreationRequest{}, %{
            board_name: board_name,
            facilitator_name: facilitator_name
          })

        conn
        |> put_flash(:error, "Internal error: Expected to find user but none found.")
        |> render("new.html", changeset: changeset)

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => board_id}) do
    user_id = Plug.Conn.get_session(conn, :user_id)

    if JoinBoard.should_prompt_user_for_identity_confirmation?(user_id, board_id) do
      redirect(conn, to: Routes.board_path(conn, :join, board_id))
    else
      live_render(conn, RetroTaxiWeb.BoardLive, session: %{"board_id" => board_id})
    end
  end

  def join(conn, %{"id" => board_id}) do
    # find and/or create user
    user_id = Plug.Conn.get_session(conn, :user_id)

    if JoinBoard.should_prompt_user_for_identity_confirmation?(user_id, board_id) do
      user =
        case Users.get_user(user_id) do
          nil -> %User{}
          user -> user
        end

      changeset = Users.change_user(user)

      board = Boards.get_board!(board_id)

      render(conn, "join.html", board: board, changeset: changeset)
    else
      redirect(conn, to: Routes.board_path(conn, :show, board_id))
    end
  end

  def post_join(conn, %{"id" => board_id, "user" => %{"display_name" => display_name}}) do
    user_id = Plug.Conn.get_session(conn, :user_id)

    user =
      case Users.get_user(user_id) do
        nil ->
          # This call will needlessly create trash users when the validation fails
          {:ok, user} = Users.register_user()
          user

        user ->
          user
      end

    IO.inspect(user)

    case Users.update_user_display_name(user, display_name) do
      {:ok, user} ->
        conn = Plug.Conn.put_session(conn, :user_id, user.id)

        {:ok, _event} = JoinBoard.create_user_identity_prompt_event(user.id, board_id)

        redirect(conn, to: Routes.board_path(conn, :show, board_id))

      {:error, _changeset} ->
        board = Boards.get_board!(board_id)

        # FIXME: This sucks but it makes the join behavior work for now. Ideally we should rethink and remove `Users.register_user/0` and instead make it so users are created/upserted in a single motion. This hack is neededd currently because the `changeset` we get back in the above case is attached to a user with an ID and so the Phoenix forms want to make a PUT request.
        changeset = Users.change_user(%User{}, %{"display_name" => display_name})

        changeset = %{changeset | action: :update}

        render(conn, "join.html", board: board, changeset: changeset)
    end

    # attempt to update or insert the user with the applied change
  end

  defp user_name_from_session(conn) do
    user_name_from_user_id(Plug.Conn.get_session(conn, :user_id))
  end

  defp user_name_from_user_id(nil), do: nil

  defp user_name_from_user_id(user_id) do
    case Users.get_user(user_id) do
      nil -> nil
      user -> user.display_name
    end
  end
end
