defmodule RetroTaxi.BoardsTest do
  use RetroTaxi.DataCase

  alias Ecto.Changeset
  alias RetroTaxi.Boards
  alias RetroTaxi.Boards.Board
  alias RetroTaxi.Boards.Column
  alias RetroTaxi.Boards.TopicCard

  describe "create_board/1" do
    test "success: works with valid name" do
      valid_name = "Test Board"
      assert {:ok, %Board{name: ^valid_name}} = Boards.create_board(name: valid_name)
    end

    test "success: new boards have expected 4 expected columns" do
      %{name: name} = params_for(:board)
      assert {:ok, %Board{columns: columns}} = Boards.create_board(name: name)
      assert length(columns) == 4
      assert Enum.find(columns, &match?(%Column{title: "Start", sort_order: 1}, &1))
      assert Enum.find(columns, &match?(%Column{title: "Stop", sort_order: 2}, &1))
      assert Enum.find(columns, &match?(%Column{title: "Continue", sort_order: 3}, &1))
      assert Enum.find(columns, &match?(%Column{title: "Actions", sort_order: 4}, &1))
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

  describe "create_topic_card/1" do
    setup context do
      %Board{columns: columns} = insert(:board)
      %Column{id: column_id} = hd(columns)

      {:ok, Map.put(context, :column_id, column_id)}
    end

    test "success: can create topic card", %{column_id: column_id} do
      sample_content = Faker.Lorem.sentence()

      assert {:ok, %TopicCard{content: ^sample_content}} =
               Boards.create_topic_card(content: sample_content, column_id: column_id)
    end

    test "failure: fails with invalid content", %{column_id: column_id} do
      invalid_content = nil

      assert {:error, changeset} =
               Boards.create_topic_card(content: invalid_content, column_id: column_id)

      assert %{content: ["can't be blank"]} = errors_on(changeset)
    end
  end
end
