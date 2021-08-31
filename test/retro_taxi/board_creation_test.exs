defmodule RetroTaxi.BoardCreationTest do
  use RetroTaxi.DataCase, async: true

  alias Ecto.Changeset
  alias RetroTaxi.BoardCreation
  alias RetroTaxi.BoardCreation.Request, as: BoardCreationRequest
  alias RetroTaxi.Boards.Board
  alias RetroTaxi.Repo
  alias RetroTaxi.Users.User

  @empty_values [nil, ""]

  describe "change_request/2" do
    test "success: returns valid changeset for expected valid values" do
      valid_attrs = board_creation_request_params(%{})

      assert %Changeset{valid?: true} =
               BoardCreation.change_request(%BoardCreationRequest{}, valid_attrs)
    end

    for value <- @empty_values do
      test "failure: fails with invalid empty board name value: #{inspect(value)}" do
        changeset =
          BoardCreation.change_request(
            %BoardCreationRequest{},
            board_creation_request_params(%{board_name: unquote(value)})
          )

        assert %{board_name: ["can't be blank"]} = errors_on(changeset)
      end

      test "failure: fails with invalid empty facilitator name value: #{inspect(value)}" do
        changeset =
          BoardCreation.change_request(
            %BoardCreationRequest{},
            board_creation_request_params(%{facilitator_name: unquote(value)})
          )

        assert %{facilitator_name: ["can't be blank"]} = errors_on(changeset)
      end
    end
  end

  describe "process_request/2" do
    test "success: creates new board and creates new user for request and nil user_id" do
      before_user_count = Repo.aggregate(from(u in User), :count, :id)

      %{board_name: board_name, facilitator_name: facilitator_name} =
        attrs = board_creation_request_params(%{})

      request = struct(BoardCreationRequest, attrs)

      result = BoardCreation.process_request(request, nil)
      after_user_count = Repo.aggregate(from(u in User), :count, :id)

      assert {:ok, %Board{name: ^board_name}, %User{display_name: ^facilitator_name}} = result
      assert after_user_count == before_user_count + 1
      # {:ok, board, user} = result
      # TODO: assert board.owner_id == user.id
    end

    test "success: creates new board and updates user for request and user_id" do
      previous_user = insert(:user)

      before_user_count = Repo.aggregate(from(u in User), :count, :id)

      %{board_name: board_name, facilitator_name: facilitator_name} =
        attrs = board_creation_request_params(%{})

      request = struct(BoardCreationRequest, attrs)

      result = BoardCreation.process_request(request, previous_user.id)
      after_user_count = Repo.aggregate(from(u in User), :count, :id)

      assert {:ok, %Board{name: ^board_name}, %User{display_name: ^facilitator_name}} = result
      assert after_user_count == before_user_count
    end

    test "failure: returns an invalid changeset when given an invalid request" do
      request = %BoardCreationRequest{board_name: nil, facilitator_name: nil}
      result = BoardCreation.process_request(request, nil)
      assert {:error, changeset} = result
      assert %{board_name: ["can't be blank"]} = errors_on(changeset)
      assert %{facilitator_name: ["can't be blank"]} = errors_on(changeset)
    end

    test "failure: returns an error/reason tuple when given an invalid user_id and does not create the board" do
      before_board_count = Repo.aggregate(from(b in Board), :count, :id)
      result = BoardCreation.process_request(valid_request(), Ecto.UUID.generate())
      after_board_count = Repo.aggregate(from(b in Board), :count, :id)

      assert {:error, :user_not_found} = result
      assert before_board_count == after_board_count
    end

    test "failure: when board creation fails, the previous user is not updated" do
      previous_user = insert(:user, display_name: "Mike")

      request =
        struct(
          BoardCreationRequest,
          board_creation_request_params(%{board_name: nil, facilitator_name: "MikeChanged"})
        )

      assert {:error, changeset} = BoardCreation.process_request(request, previous_user.id)
      assert %{board_name: ["can't be blank"]} = errors_on(changeset)
      assert Repo.get!(User, previous_user.id).display_name == "Mike"
    end

    @tag :skip
    test "failure: when user creation fails, the no new boards are persisted" do
      # This is an aspiration test for the future. Currently the implementation
      # makes an assumption that if the request is valid, the user update will
      # be valid.
    end
  end

  defp board_creation_request_params(override_attrs) do
    # Normally, I'd lean on `ex_machina` for this but this type
    # is not persisted in Ecto so there can be no real factory.
    %{
      board_name: Map.get(override_attrs, :board_name, Faker.Lorem.word()),
      facilitator_name: Map.get(override_attrs, :facilitator_name, Faker.Lorem.word())
    }
  end

  defp valid_request do
    struct(BoardCreationRequest, board_creation_request_params(%{}))
  end
end
