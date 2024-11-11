defmodule LiveTracing.Channels.Thread do
  @moduledoc false

  use Ecto.Schema

  schema "threads" do
    field :title, :string

    timestamps()
  end
end
