defmodule RetroTaxi.BoardsTest do
  use RetroTaxi.DataCase

  alias Ecto.Changeset
  alias RetroTaxi.Boards
  alias RetroTaxi.Boards.Board

  describe "create_board/1" do
    test "success: works with valid name" do
      valid_name = "Test Board"
      assert {:ok, %Board{name: ^valid_name}} = Boards.create_board(name: valid_name)
    end

    test "failure: fails with invalid name" do
      invalid_name = nil
      assert {:error, changeset} = Boards.create_board(name: invalid_name)
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "get_board!/1" do
    test "success: returns a board when given a valid id" do
      %Board{id: id} = insert(:board)
      assert %Board{id: ^id} = Boards.get_board!(id)
    end

    test "failure: raises `Ecto.NoResultsError` when given an invalid id" do
      assert_raise Ecto.NoResultsError, fn ->
        assert _will_fail = Boards.get_board!(System.unique_integer())
      end
    end
  end

  describe "change_board/2" do
    test "success: returns a changeset for a empty named struct and no attributes" do
      assert %Changeset{} = Boards.change_board(%Board{})
    end

    test "success: returns a changeset for previous entity and different attributes" do
      board = insert(:board)
      assert %Changeset{} = Boards.change_board(board, %{name: "new name"})
    end
  end
end
