defmodule ExNvccSample do
  require Logger

  @moduledoc """
  A sample program that connects Elixir and `nvcc`.
  """

  @on_load :load_nif

  def load_nif do
    nif_file = '#{Application.app_dir(:ex_nvcc_sample, "priv/libnif")}'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.error("Failed to load NIF: #{inspect(reason)}")
    end
  end

  def test, do: exit(:nif_not_loaded)

  @doc """
  Hello world.

  ## Examples

      iex> ExNvccSample.hello()
      :world

  """
  def hello do
    :world
  end
end
