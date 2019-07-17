defmodule UmsPay.Utils.Signature do
  @moduledoc """
  Module to sign data
  """

  alias UmsPay.JSON

  require JSON

  @doc """
  Generate the signature of data with API key

  ## Example

  ```elixir
  iex> UmsPay.Utils.Signature.sign(%{...}, "wx9999")
  ...> "02696FC7E3E19F852A0335F2F007DD3E"
  ```
  """
  @spec sign(map, String.t()) :: String.t()
  def sign(data, client_id) when is_map(data) do
    naive_datetime =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(8 * 3600, :second)
      |> NaiveDateTime.truncate(:second)

    timestamp =
      naive_datetime
      |> NaiveDateTime.to_string()
      |> String.replace(" ", "")
      |> String.replace("-", "")
      |> String.replace(":", "")

    nonce = UmsPay.Utils.NonceStr.generate()

    "OPEN-BODY-SIG ClientId=\"#{client_id}\", Timestamp=\"#{timestamp}\", Nonce=\"#{nonce}\", Signature=\"#{
      generate_sign_string(data, client_id, timestamp, nonce)
    }\""
  end

  defp generate_sign_string(data, client_id, timestamp, nonce) when is_map(data) do
    sign_string =
      data
      |> Map.delete(:__struct__)
      |> JSON.encode!()

    generate_sign_string(sign_string, client_id, timestamp, nonce)
  end

  defp generate_sign_string(data, client_id, timestamp, nonce) do
    sign_a =
      :sha256
      |> :crypto.hash(data)
      |> Base.encode16(case: :lower)

    :sha256
    |> :crypto.hmac(client_id, "#{client_id}#{timestamp}#{nonce}#{sign_a}")
    |> Base.encode64()
  end
end
