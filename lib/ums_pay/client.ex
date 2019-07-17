defmodule UmsPay.Client do
  @moduledoc """
   API Client
  """
  alias UmsPay.Client

  @enforce_keys [:client_id, :mch_id, :term_id]
  defstruct api_host: "https://yuedan.chinaums.com:19904/erp/bc/",
            client_id: nil,
            mch_id: nil,
            term_id: nil

  @type t :: %Client{
          api_host: String.t(),
          client_id: String.t(),
          mch_id: String.t(),
          term_id: String.t()
        }

  @spec new(Enum.t()) :: {:ok, Client.t()} | {:error, binary()}
  def new(opts) do
    attrs = Enum.into(opts, %{})

    with :ok <- validate_opts(attrs),
         client = struct(Client, attrs) do
      {:ok, client}
    end
  end

  @enforce_keys
  |> Enum.each(fn key ->
    defp unquote(:"validate_#{key}")(%{unquote(key) => value}) when not is_nil(value) do
      :ok
    end

    defp unquote(:"validate_#{key}")(_) do
      {:error, "please set `#{unquote(key)}`"}
    end
  end)

  defp validate_opts(attrs) when is_map(attrs) do
    with :ok <- validate_client_id(attrs),
         :ok <- validate_mch_id(attrs),
         :ok <- validate_term_id(attrs) do
      :ok
    end
  end
end
