defmodule RetroTaxi.JoinBoard.Request do
  @moduledoc """
  A simple value type to represent the information required during the join board task.
  """

  defstruct [:display_name]

  @type t :: %__MODULE__{
          display_name: String.t() | nil
        }
end
