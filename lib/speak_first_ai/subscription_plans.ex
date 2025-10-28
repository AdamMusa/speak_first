defmodule SpeakFirstAi.SubscriptionPlans do
  @moduledoc """
  The SubscriptionPlans context.
  """

  import Ecto.Query, warn: false
  alias SpeakFirstAi.Repo

  alias SpeakFirstAi.SubscriptionPlans.SubscriptionPlan
  alias SpeakFirstAi.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any subscription_plan changes.

  The broadcasted messages match the pattern:

    * {:created, %SubscriptionPlan{}}
    * {:updated, %SubscriptionPlan{}}
    * {:deleted, %SubscriptionPlan{}}

  """
  def subscribe_subscription_plan(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(SpeakFirstAi.PubSub, "user:#{key}:subscription_plan")
  end

  defp broadcast_subscription_plan(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(SpeakFirstAi.PubSub, "user:#{key}:subscription_plan", message)
  end

  @doc """
  Returns the list of subscription_plan.

  ## Examples

      iex> list_subscription_plan(scope)
      [%SubscriptionPlan{}, ...]

  """
  def list_subscription_plan(%Scope{} = scope) do
    Repo.all_by(SubscriptionPlan, user_id: scope.user.id)
  end

  @doc """
  Gets a single subscription_plan.

  Raises `Ecto.NoResultsError` if the Subscription plan does not exist.

  ## Examples

      iex> get_subscription_plan!(scope, 123)
      %SubscriptionPlan{}

      iex> get_subscription_plan!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription_plan!(%Scope{} = scope, id) do
    Repo.get_by!(SubscriptionPlan, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a subscription_plan.

  ## Examples

      iex> create_subscription_plan(scope, %{field: value})
      {:ok, %SubscriptionPlan{}}

      iex> create_subscription_plan(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription_plan(%Scope{} = scope, attrs) do
    with {:ok, subscription_plan = %SubscriptionPlan{}} <-
           %SubscriptionPlan{}
           |> SubscriptionPlan.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_subscription_plan(scope, {:created, subscription_plan})
      {:ok, subscription_plan}
    end
  end

  @doc """
  Updates a subscription_plan.

  ## Examples

      iex> update_subscription_plan(scope, subscription_plan, %{field: new_value})
      {:ok, %SubscriptionPlan{}}

      iex> update_subscription_plan(scope, subscription_plan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription_plan(%Scope{} = scope, %SubscriptionPlan{} = subscription_plan, attrs) do
    true = subscription_plan.user_id == scope.user.id

    with {:ok, subscription_plan = %SubscriptionPlan{}} <-
           subscription_plan
           |> SubscriptionPlan.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_subscription_plan(scope, {:updated, subscription_plan})
      {:ok, subscription_plan}
    end
  end

  @doc """
  Deletes a subscription_plan.

  ## Examples

      iex> delete_subscription_plan(scope, subscription_plan)
      {:ok, %SubscriptionPlan{}}

      iex> delete_subscription_plan(scope, subscription_plan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription_plan(%Scope{} = scope, %SubscriptionPlan{} = subscription_plan) do
    true = subscription_plan.user_id == scope.user.id

    with {:ok, subscription_plan = %SubscriptionPlan{}} <-
           Repo.delete(subscription_plan) do
      broadcast_subscription_plan(scope, {:deleted, subscription_plan})
      {:ok, subscription_plan}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription_plan changes.

  ## Examples

      iex> change_subscription_plan(scope, subscription_plan)
      %Ecto.Changeset{data: %SubscriptionPlan{}}

  """
  def change_subscription_plan(%Scope{} = scope, %SubscriptionPlan{} = subscription_plan, attrs \\ %{}) do
    true = subscription_plan.user_id == scope.user.id

    SubscriptionPlan.changeset(subscription_plan, attrs, scope)
  end
end
