defmodule SpeakFirstAiWeb.SubscriptionPlanLive.Form do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.SubscriptionPlans
  alias SpeakFirstAi.SubscriptionPlans.SubscriptionPlan

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto">
      <div class="bg-white border-2 border-gray-100 rounded-3xl shadow-xl p-8 lg:p-10">
        <.header>
          {@page_title}
          <:subtitle>Use this form to manage subscription plan records in your database.</:subtitle>
        </.header>

        <.form for={@form} id="subscription_plan-form" phx-change="validate" phx-submit="save" class="mt-8 space-y-6">
          <.input field={@form[:name]} type="text" label="Name" />
          <.input field={@form[:description]} type="textarea" label="Description" />
          <.input field={@form[:price_cents]} type="number" label="Price cents" step="any" />
          <.input field={@form[:currency]} type="text" label="Currency" />
          <.input field={@form[:interval]} type="text" label="Interval" />
          <.input field={@form[:stripe_price_id]} type="text" label="Stripe price" />
          <.input field={@form[:active]} type="checkbox" label="Active" />
          <.input field={@form[:trial_period_days]} type="number" label="Trial period days" />
          <div class="mt-8 flex items-center gap-4 pt-6 border-t border-gray-200">
            <button
              type="submit"
              phx-disable-with="Saving..."
              class="group relative inline-flex items-center gap-2 px-6 py-3 text-sm font-semibold rounded-2xl bg-gradient-to-r from-gray-900 to-gray-800 text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 transform overflow-hidden"
            >
              <span class="absolute inset-0 bg-gradient-to-r from-blue-600 to-purple-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
              <span class="relative flex items-center gap-2">
                <.icon name="hero-check" class="w-5 h-5" />
                Save Subscription plan
              </span>
            </button>
            <.link
              navigate={return_path(@current_scope, @return_to, @subscription_plan)}
              class="px-6 py-3 text-sm font-semibold rounded-2xl border-2 border-gray-200 text-gray-700 hover:border-gray-300 hover:bg-gray-50 transition-all duration-300 hover:scale-105 transform shadow-sm"
            >
              Cancel
            </.link>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    subscription_plan = SubscriptionPlans.get_subscription_plan!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Subscription plan")
    |> assign(:subscription_plan, subscription_plan)
    |> assign(
      :form,
      to_form(
        SubscriptionPlans.change_subscription_plan(
          socket.assigns.current_scope,
          subscription_plan
        )
      )
    )
  end

  defp apply_action(socket, :new, _params) do
    subscription_plan = %SubscriptionPlan{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Subscription plan")
    |> assign(:subscription_plan, subscription_plan)
    |> assign(
      :form,
      to_form(
        SubscriptionPlans.change_subscription_plan(
          socket.assigns.current_scope,
          subscription_plan
        )
      )
    )
  end

  @impl true
  def handle_event("validate", %{"subscription_plan" => subscription_plan_params}, socket) do
    changeset =
      SubscriptionPlans.change_subscription_plan(
        socket.assigns.current_scope,
        socket.assigns.subscription_plan,
        subscription_plan_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"subscription_plan" => subscription_plan_params}, socket) do
    save_subscription_plan(socket, socket.assigns.live_action, subscription_plan_params)
  end

  defp save_subscription_plan(socket, :edit, subscription_plan_params) do
    case SubscriptionPlans.update_subscription_plan(
           socket.assigns.current_scope,
           socket.assigns.subscription_plan,
           subscription_plan_params
         ) do
      {:ok, subscription_plan} ->
        {:noreply,
         socket
         |> put_flash(:info, "Subscription plan updated successfully")
         |> push_navigate(
           to:
             return_path(
               socket.assigns.current_scope,
               socket.assigns.return_to,
               subscription_plan
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_subscription_plan(socket, :new, subscription_plan_params) do
    case SubscriptionPlans.create_subscription_plan(
           socket.assigns.current_scope,
           subscription_plan_params
         ) do
      {:ok, subscription_plan} ->
        {:noreply,
         socket
         |> put_flash(:info, "Subscription plan created successfully")
         |> push_navigate(
           to:
             return_path(
               socket.assigns.current_scope,
               socket.assigns.return_to,
               subscription_plan
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _subscription_plan), do: ~p"/admin/subscription_plans"

  defp return_path(_scope, "show", subscription_plan),
    do: ~p"/admin/subscription_plans/#{subscription_plan}"
end
