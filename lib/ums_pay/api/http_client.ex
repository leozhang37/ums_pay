defmodule UmsPay.HttpClient do
  alias UmsPay.JSON
  alias UmsPay.Error

  require JSON
  require Logger

  def post(client, path, attrs, options) do
    path = client.api_host |> URI.merge(path) |> to_string()

    request_data =
      attrs
      |> append_ids(client.mch_id, client.term_id)

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"Authorization", UmsPay.Utils.Signature.sign(request_data, client.client_id)}
    ]

    Logger.debug("Authorization: #{UmsPay.Utils.Signature.sign(request_data, client.client_id)}")

    request_data =
      request_data
      |> JSON.encode!()

    Logger.info("[ums_pay] url: #{inspect(path)} request data: #{inspect(request_data)}")

    with {:ok, response} <- HTTPoison.post(path, request_data, headers, options),
         {:ok, response_data} <- process_response(response),
         {:ok, data} <- process_result_field(response_data) do
      {:ok, data}
    end
  end

  defp append_ids(data, mch_id, term_id) when is_map(data) do
    data
    |> Map.merge(%{
      merchantCode: mch_id,
      terminalCode: term_id
    })
  end

  defp process_response(%HTTPoison.Response{status_code: 200, body: body}) do
    body
    |> JSON.decode()
  end

  defp process_response(%HTTPoison.Response{status_code: 201, body: body}) do
    {:error, %Error{reason: body, type: :unprocessable_entity}}
  end

  defp process_response(%HTTPoison.Response{status_code: 404, body: _body}) do
    {:error, %Error{reason: "The endpoint is not found", type: :not_found}}
  end

  defp process_response(%HTTPoison.Response{status_code: 502, body: _body}) do
    {:error, %Error{reason: "银联网关错误502", type: :unknown_response}}
  end

  defp process_response(%HTTPoison.Response{body: body} = response) do
    Logger.debug("#{inspect(response)}")
    {:error, %Error{reason: body, type: :unknown_response}}
  end

  # handle result
  defp process_result_field(%{errCode: "00"} = data) do
    {:ok, data}
  end

  defp process_result_field(%{errCode: "PG", errInfo: err_info}) do
    {:error, %Error{reason: "Code: PG, msg: #{err_info}", type: :unkown_result}}
  end

  defp process_result_field(%{errCode: err_code, errInfo: err_info}) do
    {:error, %Error{reason: "Code: #{err_code}, msg: #{err_info}", type: :failed_result}}
  end
end
