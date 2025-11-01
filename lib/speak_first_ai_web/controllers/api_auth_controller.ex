defmodule SpeakFirstAiWeb.ApiAuthController do
  use SpeakFirstAiWeb, :controller

  alias SpeakFirstAi.Accounts
  alias SpeakFirstAiWeb.ApiAuthJSON

  @doc """
  Registers a new user via API.

  Expects JSON body:
  ```json
  {
    "email": "user@example.com",
    "password": "securepassword123"
  }
  ```

  Returns:
  ```json
  {
    "user": {
      "id": 1,
      "email": "user@example.com"
    },
    "access_token": "encoded_access_token",
    "refresh_token": "encoded_refresh_token"
  }
  ```
  """
  def register(conn, %{"email" => email, "password" => password}) do
    case Accounts.register_user_with_password(%{
           "email" => email,
           "password" => password
         }) do
      {:ok, user} ->
        {access_token, refresh_token} = Accounts.generate_api_tokens(user)
        encoded_access_token = Base.url_encode64(access_token, padding: false)
        encoded_refresh_token = Base.url_encode64(refresh_token, padding: false)

        conn
        |> put_status(:created)
        |> json(
          ApiAuthJSON.render("register.json", %{
            user: user,
            access_token: encoded_access_token,
            refresh_token: encoded_refresh_token
          })
        )

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(ApiAuthJSON.render("error.json", %{changeset: changeset}))
    end
  end

  def register(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "email and password are required"})
  end

  @doc """
  Logs in a user via API.

  Expects JSON body:
  ```json
  {
    "email": "user@example.com",
    "password": "securepassword123"
  }
  ```

  Returns:
  ```json
  {
    "user": {
      "id": 1,
      "email": "user@example.com"
    },
    "access_token": "encoded_access_token",
    "refresh_token": "encoded_refresh_token"
  }
  ```
  """
  def login(conn, %{"email" => email, "password" => password}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      {access_token, refresh_token} = Accounts.generate_api_tokens(user)
      encoded_access_token = Base.url_encode64(access_token, padding: false)
      encoded_refresh_token = Base.url_encode64(refresh_token, padding: false)

      conn
      |> put_status(:ok)
      |> json(
        ApiAuthJSON.render("login.json", %{
          user: user,
          access_token: encoded_access_token,
          refresh_token: encoded_refresh_token
        })
      )
    else
      # Don't disclose whether the email exists for security
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Invalid email or password"})
    end
  end

  def login(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "email and password are required"})
  end

  @doc """
  Refreshes an access token using a refresh token.

  Expects JSON body:
  ```json
  {
    "refresh_token": "encoded_refresh_token"
  }
  ```

  Returns:
  ```json
  {
    "access_token": "new_encoded_access_token",
    "refresh_token": "new_encoded_refresh_token"
  }
  ```
  """
  def refresh(conn, %{"refresh_token" => refresh_token}) do
    case Accounts.refresh_access_token(refresh_token) do
      {:ok, {access_token, new_refresh_token}} ->
        encoded_access_token = Base.url_encode64(access_token, padding: false)
        encoded_refresh_token = Base.url_encode64(new_refresh_token, padding: false)

        conn
        |> put_status(:ok)
        |> json(
          ApiAuthJSON.render("refresh.json", %{
            access_token: encoded_access_token,
            refresh_token: encoded_refresh_token
          })
        )

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or expired refresh token"})
    end
  end

  def refresh(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "refresh_token is required"})
  end
end
