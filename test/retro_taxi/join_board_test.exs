defmodule RetroTaxi.JoinBoardTest do
  use RetroTaxi.DataCase, async: true

  alias RetroTaxi.Boards.Board
  alias RetroTaxi.JoinBoard
  alias RetroTaxi.JoinBoard.UserIdentityPromptEvent
  alias RetroTaxi.Users.User

  describe "should_prompt_user_for_identity_confirmation?/2" do
    test "success: returns true when existing user has not been previously prompted" do
      %User{id: user_id} = insert(:user)
      %Board{id: board_id} = insert(:board)

      assert JoinBoard.should_prompt_user_for_identity_confirmation?(user_id, board_id)
    end

    test "success: returns false when existing user has been previously prompted" do
      %UserIdentityPromptEvent{user_id: user_id, board_id: board_id} =
        insert(:user_identity_prompt_event)

      refute JoinBoard.should_prompt_user_for_identity_confirmation?(user_id, board_id)
    end

    test "success: returns true when user id is nil (and board does exist)" do
      %Board{id: board_id} = insert(:board)

      assert JoinBoard.should_prompt_user_for_identity_confirmation?(nil, board_id)
    end

    test "failure: return :board_not_found when a board can not be found." do
      random_number = :rand.uniform(9999)

      assert JoinBoard.should_prompt_user_for_identity_confirmation?(nil, random_number) ==
               :board_not_found

      %User{id: user_id} = insert(:user)

      assert JoinBoard.should_prompt_user_for_identity_confirmation?(
               user_id,
               random_number
             ) == :board_not_found
    end
  end
end
