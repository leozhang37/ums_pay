defmodule UmsPay.Api do
  @moduledoc """
  The Core Api
  """

  alias UmsPay.HttpClient
  alias UmsPay.Client
  alias UmsPay.Error

  @doc """
   支付
  """
  @spec pay(Client.t(), map, keyword) :: {:ok, map} | {:error, Error.t() | HTTPoison.Error.t()}
  def pay(client, attrs, options \\ []) do
    with {:ok, data} <- HttpClient.post(client, "pay", attrs, options) do
      {:ok, data}
    end
  end

  @doc """
    查询
  """
  @spec query(Client.t(), map, keyword) :: {:ok, map} | {:error, Error.t() | HTTPoison.Error.t()}
  def query(client, attrs, options \\ []) do
    with {:ok, data} <- HttpClient.post(client, "query", attrs, options) do
      {:ok, data}
    end
  end

  @doc """
    撤消
  """
  @spec reverse(Client.t(), map, keyword) ::
          {:ok, map} | {:error, Error.t() | HTTPoison.Error.t()}
  def reverse(client, attrs, options \\ []) do
    with {:ok, data} <- HttpClient.post(client, "reverse", attrs, options) do
      {:ok, data}
    end
  end

  @doc """
    退款
  """
  @spec refund(Client.t(), map, keyword) :: {:ok, map} | {:error, Error.t() | HTTPoison.Error.t()}
  def refund(client, attrs, options \\ []) do
    with {:ok, data} <- HttpClient.post(client, "refund", attrs, options) do
      {:ok, data}
    end
  end
end
