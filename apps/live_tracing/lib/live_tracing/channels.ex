defmodule LiveTracing.Channels do
  @moduledoc """
  The Channels context.
  """
  alias LiveTracing.Repo
  alias __MODULE__.Thread

  def list_threads do
    Repo.all(Thread)
  end
end
