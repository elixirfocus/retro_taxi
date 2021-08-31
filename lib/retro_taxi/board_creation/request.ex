defmodule RetroTaxi.BoardCreation.Request do
  @moduledoc """
  A simple value type to represent the information required during the board creation task.
  """

  defstruct [:board_name, :facilitator_name]

  @type t :: %__MODULE__{
          board_name: String.t() | nil,
          facilitator_name: String.t() | nil
        }
end
