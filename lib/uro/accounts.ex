defmodule Uro.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Uro.Repo

  alias Uro.Accounts.User

  @user_associated_schemas [:user_privilege_ruleset]

  def get_by_username(username) when is_nil(username) do
    nil
  end
  def get_by_username(username) do
    User
    |> Repo.get_by(username: username)
    |> Repo.preload(@user_associated_schemas)
  end

  def get_by_email(email) when is_nil(email) do
    nil
  end
  def get_by_email(email) do
    User
    |> Repo.get_by(email: email)
    |> Repo.preload(@user_associated_schemas)
  end

  def get_by_username_or_email(username_or_email) when is_nil(username_or_email) do
    nil
  end
  def get_by_username_or_email(username_or_email) do
    User
    |> where(username: ^username_or_email)
    |> or_where(email: ^username_or_email)
    |> Repo.one
    |> Repo.preload(@user_associated_schemas)
  end

  def list_users_admin do
    User
    |> Repo.all
    |> Repo.preload(@user_associated_schemas)
  end

  def list_users_admin(params) do
    search_term = get_in(params, ["query"])

    User
    |> User.admin_search(search_term)
    |> Repo.all
    |> Repo.preload(@user_associated_schemas)
  end

  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(@user_associated_schemas)
  end

  def create_user_privilege_ruleset_for_user(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:user_privilege_ruleset, attrs)
    |> Repo.insert()
  end

  def create_associated_entries_for_user(user) do
    user
    |> create_user_privilege_ruleset_for_user
    user
  end

  def create_user(conn, attrs) do
    conn
    |> Pow.Plug.create_user(attrs)
    |> case do
      {:ok, user, conn} ->
        user
        |> create_associated_entries_for_user
        {:ok, user, conn}
      {:error, changeset, conn} ->
        {:error, changeset, conn}
    end
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def update_current_user(conn, attrs) do
    conn
    |> Pow.Plug.update_user(attrs)
  end

  def delete_current_user(conn) do
    conn
    |> Pow.Plug.delete_user
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
