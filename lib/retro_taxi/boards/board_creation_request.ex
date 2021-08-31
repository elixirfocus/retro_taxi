defmodule RetroTaxi.Boards.BoardCreationRequest do
  defstruct [:board_name, :facilitator_name]

  @type t :: %__MODULE__{
          board_name: String.t(),
          facilitator_name: String.t()
        }
end
