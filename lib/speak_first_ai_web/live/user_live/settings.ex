defmodule SpeakFirstAiWeb.UserLive.Settings do
  use SpeakFirstAiWeb, :live_view

  on_mount {SpeakFirstAiWeb.UserAuth, :require_sudo_mode}

  alias SpeakFirstAi.{Accounts, Subscriptions}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-white py-8">
        <div class="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          <%!-- Header --%>
          <div class="mb-8">
            <h1 class="text-3xl sm:text-4xl font-bold text-gray-900 mb-2">
              Profile Settings
            </h1>
            <p class="text-gray-600">Manage your account settings and subscription</p>
          </div>

          <div class="space-y-6">
            <%!-- Profile Info Card --%>
            <div class="bg-white rounded-3xl shadow-xl border-2 border-gray-100 p-6 lg:p-8">
              <div class="flex items-center gap-4 mb-6 pb-6 border-b border-gray-200">
                <div class="w-16 h-16 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white text-2xl font-bold shadow-lg">
                  {String.first(@current_scope.user.email) |> String.upcase()}
                </div>
                <div class="flex-1">
                  <h2 class="text-xl font-bold text-gray-900">Account Information</h2>
                  <p class="text-gray-600 text-sm mt-1">{@current_scope.user.email}</p>
                </div>
              </div>

              <%!-- Email Update Section --%>
              <div class="space-y-4">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">Email Address</h3>
                <.form for={@email_form} id="email_form" phx-submit="update_email" phx-change="validate_email" class="space-y-4">
                  <.input
                    field={@email_form[:email]}
                    type="email"
                    label="Email"
                    autocomplete="username"
                    required
                  />
                  <button
                    type="submit"
                    phx-disable-with="Changing..."
                    class="group relative inline-flex items-center gap-2 px-6 py-3 text-sm font-semibold rounded-2xl bg-gradient-to-r from-gray-900 to-gray-800 text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 transform overflow-hidden"
                  >
                    <span class="absolute inset-0 bg-gradient-to-r from-blue-600 to-purple-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
                    <span class="relative flex items-center gap-2">
                      <.icon name="hero-envelope" class="w-5 h-5" />
                      Change Email
                    </span>
                  </button>
                </.form>
              </div>
            </div>

            <%!-- Password Update Card --%>
            <div class="bg-white rounded-3xl shadow-xl border-2 border-gray-100 p-6 lg:p-8">
              <div class="mb-6">
                <h2 class="text-xl font-bold text-gray-900 mb-2">Change Password</h2>
                <p class="text-gray-600 text-sm">Update your password to keep your account secure</p>
              </div>

              <.form
                for={@password_form}
                id="password_form"
                action={~p"/users/update-password"}
                method="post"
                phx-change="validate_password"
                phx-submit="update_password"
                phx-trigger-action={@trigger_submit}
                class="space-y-6"
              >
                <input
                  name={@password_form[:email].name}
                  type="hidden"
                  id="hidden_user_email"
                  autocomplete="username"
                  value={@current_email}
                />
                <.input
                  field={@password_form[:password]}
                  type="password"
                  label="New password"
                  autocomplete="new-password"
                  required
                />
                <.input
                  field={@password_form[:password_confirmation]}
                  type="password"
                  label="Confirm new password"
                  autocomplete="new-password"
                />
                <div class="pt-4 border-t border-gray-200">
                  <button
                    type="submit"
                    phx-disable-with="Saving..."
                    class="group relative inline-flex items-center gap-2 px-6 py-3 text-sm font-semibold rounded-2xl bg-gradient-to-r from-gray-900 to-gray-800 text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 transform overflow-hidden"
                  >
                    <span class="absolute inset-0 bg-gradient-to-r from-blue-600 to-purple-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
                    <span class="relative flex items-center gap-2">
                      <.icon name="hero-lock-closed" class="w-5 h-5" />
                      Save Password
                    </span>
                  </button>
                </div>
              </.form>
            </div>

            <%!-- Subscription Card --%>
            <div class="bg-white rounded-3xl shadow-xl border-2 border-gray-100 p-6 lg:p-8">
              <div class="flex items-center justify-between mb-6 pb-6 border-b border-gray-200">
                <div>
                  <h2 class="text-xl font-bold text-gray-900 mb-2">Subscription</h2>
                  <p class="text-gray-600 text-sm">Manage your subscription and billing</p>
                </div>
                <.link
                  navigate={~p"/subscriptions"}
                  class="group relative inline-flex items-center gap-2 px-5 py-2.5 text-sm font-semibold rounded-2xl bg-gradient-to-r from-gray-900 to-gray-800 text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 transform overflow-hidden"
                >
                  <span class="absolute inset-0 bg-gradient-to-r from-blue-600 to-purple-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
                  <span class="relative flex items-center gap-2">
                    <.icon name="hero-credit-card" class="w-5 h-5" />
                    Manage Subscription
                  </span>
                </.link>
              </div>

              <%= if @subscription do %>
                <% subscription_active? = @subscription.status == "active" && !@subscription.cancel_at_period_end %>
                <% format_price = fn cents, currency ->
                  amount = Float.round(cents / 100, 2)
                  symbol = case String.downcase(currency || "usd") do
                    "usd" -> "$"
                    "eur" -> "€"
                    "gbp" -> "£"
                    _ -> ""
                  end
                  "#{symbol}#{:erlang.float_to_binary(amount, [{:decimals, 2}])}"
                end %>

                <div class="space-y-4">
                  <div class="flex items-center justify-between py-3 border-b border-gray-200">
                    <span class="text-gray-600 font-medium">Current Plan</span>
                    <div class="flex items-center gap-3">
                      <span class="font-bold text-gray-900">
                        <%= @subscription.subscription_plan && @subscription.subscription_plan.name || @subscription.plan || "N/A" %>
                      </span>
                      <%= cond do %>
                        <% subscription_active? -> %>
                          <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-green-50 text-green-600 border border-green-200">
                            <.icon name="hero-check-circle" class="w-3 h-3 mr-1" />
                            Active
                          </span>
                        <% @subscription.status == "canceled" || @subscription.cancel_at_period_end -> %>
                          <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-red-50 text-red-600 border border-red-200">
                            <.icon name="hero-x-circle" class="w-3 h-3 mr-1" />
                            Canceled
                          </span>
                        <% @subscription.status == "trialing" -> %>
                          <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-blue-50 text-blue-600 border border-blue-200">
                            <.icon name="hero-clock" class="w-3 h-3 mr-1" />
                            Trialing
                          </span>
                        <% true -> %>
                          <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-yellow-50 text-yellow-600 border border-yellow-200">
                            <.icon name="hero-exclamation-triangle" class="w-3 h-3 mr-1" />
                            <%= String.capitalize(@subscription.status || "Unknown") %>
                          </span>
                      <% end %>
                    </div>
                  </div>

                  <%= if @subscription.subscription_plan do %>
                    <div class="flex items-center justify-between py-3 border-b border-gray-200">
                      <span class="text-gray-600 font-medium">Billing Cycle</span>
                      <span class="font-semibold text-gray-900"><%= @subscription.subscription_plan.interval %></span>
                    </div>
                    <div class="flex items-center justify-between py-3 border-b border-gray-200">
                      <span class="text-gray-600 font-medium">Amount</span>
                      <span class="font-semibold text-gray-900">
                        <%= format_price.(@subscription.subscription_plan.price_cents, @subscription.subscription_plan.currency) %>
                      </span>
                    </div>
                  <% end %>

                  <%= if @subscription.current_period_end do %>
                    <div class="flex items-center justify-between py-3 border-b border-gray-200">
                      <span class="text-gray-600 font-medium">Next Billing Date</span>
                      <span class="font-semibold text-gray-900">
                        <%= Calendar.strftime(@subscription.current_period_end, "%B %d, %Y") %>
                      </span>
                    </div>
                  <% end %>

                  <%= if @subscription.inserted_at do %>
                    <div class="flex items-center justify-between py-3">
                      <span class="text-gray-600 font-medium">Started</span>
                      <span class="font-semibold text-gray-900">
                        <%= Calendar.strftime(@subscription.inserted_at, "%B %d, %Y") %>
                      </span>
                    </div>
                  <% end %>
                </div>
              <% else %>
                <div class="text-center py-8">
                  <div class="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mx-auto mb-4">
                    <.icon name="hero-credit-card" class="w-8 h-8 text-gray-400" />
                  </div>
                  <p class="text-gray-600 mb-4">No active subscription found</p>
                  <.link
                    navigate={~p"/#pricing"}
                    class="inline-flex items-center gap-2 px-5 py-2.5 text-sm font-semibold rounded-2xl border-2 border-gray-200 text-gray-700 hover:border-gray-300 hover:bg-gray-50 transition-all duration-300 hover:scale-105 transform"
                  >
                    View Plans
                    <.icon name="hero-arrow-right" class="w-5 h-5" />
                  </.link>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "Email changed successfully.")

        {:error, _} ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    email_changeset = Accounts.change_user_email(user, %{}, validate_unique: false)
    password_changeset = Accounts.change_user_password(user, %{}, hash_password: false)
    subscription = Subscriptions.get_user_subscription(user)

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> assign(:subscription, subscription)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params

    email_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_email(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_user_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          user.email,
          &url(~p"/users/settings/confirm-email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"user" => user_params} = params

    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_password(user, user_params) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}

      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end
end
