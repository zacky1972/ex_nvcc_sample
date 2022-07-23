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

  def add_s32(x, y), do: add(x, y, {:s, 32})

  def add(x, y, type) when is_struct(x, Nx.Tensor) and is_struct(y, Nx.Tensor) do
    add_sub(Nx.as_type(x, type), Nx.as_type(y, type), type)
  end

  def add(x, y, type) when is_number(x) do
    add(Nx.tensor([x]), y, type)
  end

  def add(x, y, type) when is_number(y) do
    add(x, Nx.tensor([y]), type)
  end

  defp add_sub(x, y, type) do
    if Nx.shape(x) == Nx.shape(y) do
      %{
        x
        | data: %{
          x.data
          | state: add_sub_sub(Nx.size(x), Nx.shape(x), x.data.state, y.data.state, type)
        }
      }
    else
      raise RuntimeError, "shape is not much add(#{inspect Nx.shape(x)}, #{inspect Nx.shape(y)})"
    end
  end

  defp add_sub_sub(size, shape, binary1, binary2, {:s, 32}) do
    add_s32_nif(size, shape, binary1, binary2)
  end

  def add_s32_nif(_size, _shape, _binary1, _binary2), do: exit(:nif_not_loaded)

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