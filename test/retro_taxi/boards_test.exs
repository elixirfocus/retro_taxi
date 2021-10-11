defmodule RetroTaxi.BoardsTest do
  use RetroTaxi.DataCase

  alias Ecto.Changeset
  alias RetroTaxi.Boards
  alias RetroTaxi.Boards.Board
  alias RetroTaxi.Boards.Column
  alias RetroTaxi.Boards.TopicCard
  alias RetroTaxi.Users.User

  describe "create_board/2" do
    test "success: works with valid name" do
      %User{id: facilitator_id} = insert(:user)
      valid_name = "Test Board"

      assert {:ok, %Board{name: ^valid_name, facilitator_id: ^facilitator_id}} =
               Boards.create_board(valid_name, facilitator_id)
    end

    test "success: new boards have expected 4 expected columns" do
      %User{id: facilitator_id} = insert(:user)
      %{name: name} = params_for(:board)
      assert {:ok, %Board{columns: columns}} = Boards.create_board(name, facilitator_id)
      assert length(columns) == 4
      assert Enum.find(columns, &match?(%Column{title: "Start", sort_order: 1}, &1))
      assert Enum.find(columns, &match?(%Column{title: "Stop", sort_order: 2}, &1))
      assert Enum.find(columns, &match?(%Column{title: "Continue", sort_order: 3}, &1))
      assert Enum.find(columns, &match?(%Column{title: "Actions", sort_order: 4}, &1))
    end

    test "failure: fails with invalid name" do
      %User{id: facilitator_id} = insert(:user)

      invalid_name = nil
      assert {:error, changeset} = Boards.create_board(invalid_name, facilitator_id)
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
        assert _will_fail = Boards.get_board!("20f17037-69dc-402e-8acf-b6f9a5fb732a")
      end
    end
  end

  describe "change_board/2" do
    test "success: returns a changeset for an empty named struct and no attributes" do
      assert %Changeset{} = Boards.change_board(%Board{})
    end

    test "success: returns a changeset for the given entity and new attributes" do
      user = insert(:user)
      board = insert(:board)

      assert %Changeset{} =
               Boards.change_board(board, %{name: "new name", facilitator_id: user.id})
    end
  end

  describe "create_topic_card/2" do
    setup context do
      %Board{columns: columns} = insert(:board)
      %Column{id: column_id} = hd(columns)

      {:ok, Map.put(context, :column_id, column_id)}
    end

    test "success: can create topic card", %{column_id: column_id} do
      %{content: content, author_id: author_id} = params_for(:topic_card, author: insert(:user))

      assert {:ok, %TopicCard{content: ^content}} =
               Boards.create_topic_card(%{
                 content: content,
                 column_id: column_id,
                 author_id: author_id
               })
    end

    test "success: a new topic card will have a sort order that matches the previous count plus one",
         %{column_id: column_id} do
      insert_list(3, :topic_card, column_id: column_id)

      %{content: content, author_id: author_id} = params_for(:topic_card, author: insert(:user))

      assert {:ok, %TopicCard{content: ^content, sort_order: 4}} =
               Boards.create_topic_card(%{
                 content: content,
                 column_id: column_id,
                 author_id: author_id
               })
    end

    test "failure: fails with invalid content", %{column_id: column_id} do
      invalid_content = nil

      assert {:error, changeset} =
               Boards.create_topic_card(%{
                 content: invalid_content,
                 column_id: column_id,
                 author_id: nil
               })

      assert %{content: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "change_topic_card/2" do
    test "success: returns a changeset for a empty named struct and no attributes" do
      assert %Changeset{} = Boards.change_topic_card(%TopicCard{})
    end

    test "success: returns a changeset for the given entity and new attributes" do
      topic_card = insert(:topic_card)
      assert %Changeset{} = Boards.change_topic_card(topic_card, %{content: "new content"})
    end
  end

  describe "list_topic_cards/1" do
    setup context do
      %Board{columns: columns} = insert(:board)
      %Column{id: column_id} = hd(columns)

      {:ok, Map.put(context, :column_id, column_id)}
    end

    test "success: returns the expected list of entities", %{column_id: column_id} do
      [
        %TopicCard{content: content_1},
        %TopicCard{content: content_2},
        %TopicCard{content: content_3},
        %TopicCard{content: content_4}
      ] = insert_list(4, :topic_card, column_id: column_id)

      fetched_topic_cards = Boards.list_topic_cards(column_id: column_id)

      assert length(fetched_topic_cards) == 4
      assert Enum.find(fetched_topic_cards, &match?(%TopicCard{content: ^content_1}, &1))
      assert Enum.find(fetched_topic_cards, &match?(%TopicCard{content: ^content_2}, &1))
      assert Enum.find(fetched_topic_cards, &match?(%TopicCard{content: ^content_3}, &1))
      assert Enum.find(fetched_topic_cards, &match?(%TopicCard{content: ^content_4}, &1))
    end
  end

  describe "count_topic_cards/1" do
    setup context do
      %Board{columns: columns} = insert(:board)
      %Column{id: column_id} = hd(columns)

      {:ok, Map.put(context, :column_id, column_id)}
    end

    test "success: returns the expected count of entities", %{column_id: column_id} do
      insert_list(4, :topic_card, column_id: column_id)

      assert 4 == Boards.count_topic_cards(column_id: column_id)
    end
  end
end
