defmodule UroWeb.Helpers.Auth do
  def validate_user_params(user_params) do
    Enum.all?(["username_or_email", "password"], fn x -> Map.has_key?(user_params, x) end)
  end

  def validate_login(conn, user_params) do
    if validate_user_params(user_params) do
      user = Uro.Accounts.get_by_username_or_email(user_params["username_or_email"] |> String.downcase)

      if user do
        conn
        |> Pow.Plug.authenticate_user(%{"email" => user.email, "password" => user_params["password"]})
      else
        {:error, conn}
      end
    else
      {:error, conn}
    end
  end

  def signed_in?(conn) do
    if Pow.Plug.current_user(conn) do
      true
    end
  end

  def get_user(conn) do
    Pow.Plug.current_user(conn)
  end

  def session_username(conn) do
    user = get_user(conn)
    if user do
      if user.username do
        user.username
      else
        "[NULL]"
      end
    end
  end

    def session_display_name(conn) do
      user = get_user(conn)
      if user do
        if user.display_name do
          user.display_name
        else
          "[NULL]"
        end
      end
  end

  @doc false
  defmacro __using__(_config) do
    quote do
      import unquote(__MODULE__), only: [validate_login: 2]
    end
  end
end
