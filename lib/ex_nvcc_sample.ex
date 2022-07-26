defmodule ExNvccSample do
  require Logger

  @moduledoc """
  A sample program that connects Elixir and `nvcc`.
  """

  @on_load :load_nif

  @doc false
  def load_nif do
    nif_file = ~c'#{Application.app_dir(:ex_nvcc_sample, "priv/libnif")}'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.error("Failed to load NIF: #{inspect(reason)}")
    end
  end

  @doc """
  Add two tensors with signed 32bit integer.
  ## Examples

      iex> ExNvccSample.add_s32(0, 1)
      #Nx.Tensor<
        s32[1]
        [1]
      >

      iex> ExNvccSample.add_s32(Nx.tensor([0, 1, 2, 3]), Nx.tensor([3, 2, 1, 0]))
      #Nx.Tensor<
        s32[4]
        [3, 3, 3, 3]
      >

  """
  def add_s32(x, y), do: add(x, y, {:s, 32})

  @doc false
  def add(x, y, type) when is_struct(x, Nx.Tensor) and is_struct(y, Nx.Tensor) do
    add_sub(Nx.as_type(x, type), Nx.as_type(y, type), type)
  end

  @doc false
  def add(x, y, type) when is_number(x) do
    add(Nx.tensor([x]), y, type)
  end

  @doc false
  def add(x, y, type) when is_number(y) do
    add(x, Nx.tensor([y]), type)
  end

  defp add_sub(x, y, type) do
    if Nx.shape(x) == Nx.shape(y) do
      Nx.from_binary(add_sub_sub(Nx.size(x), Nx.shape(x), Nx.to_binary(x), Nx.to_binary(y), type), type)
    else
      raise RuntimeError, "shape is not much add(#{inspect Nx.shape(x)}, #{inspect Nx.shape(y)})"
    end
  end

  defp add_sub_sub(size, shape, binary1, binary2, {:s, 32}) do
    try do
      add_s32_nif(size, shape, binary1, binary2)
    rescue
      e in ErlangError -> raise RuntimeError, message: List.to_string(e.original)
    end
  end

  @doc false
  def add_s32_nif(_size, _shape, _binary1, _binary2), do: :erlang.nif_error(:not_loaded)
end
