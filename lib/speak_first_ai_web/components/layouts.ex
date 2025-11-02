defmodule SpeakFirstAiWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use SpeakFirstAiWeb, :html
  import Phoenix.Controller, only: [get_csrf_token: 0]
  alias Phoenix.LiveView.JS

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main>
      <header class="w-full sticky top-0 z-50 bg-white/95 backdrop-blur-md border-b border-gray-200/80 shadow-sm">
        <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div class="flex items-center gap-8">
            <.link navigate={~p"/"} class="flex items-center gap-2 group">
              <span class="text-xl font-bold text-gray-900 tracking-tight group-hover:opacity-80 transition-opacity duration-200">
                <span class="bg-gradient-to-r from-blue-600 via-purple-600 to-indigo-600 bg-clip-text text-transparent">
                  SpeakFirst
                </span>
              </span>
            </.link>
            <nav class="hidden md:flex items-center gap-8 text-sm">
              <a
                href="#download"
                class="text-gray-600 hover:text-gray-900 font-medium transition-colors duration-200 relative group"
              >
                Download
                <span class="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-blue-600 to-purple-600 group-hover:w-full transition-all duration-300"></span>
              </a>
              <a
                href="#pricing"
                class="text-gray-600 hover:text-gray-900 font-medium transition-colors duration-200 relative group"
              >
                Pricing
                <span class="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-blue-600 to-purple-600 group-hover:w-full transition-all duration-300"></span>
              </a>
            </nav>
          </div>

          <div class="hidden md:flex items-center gap-3">
            <%= if @current_scope && @current_scope.user do %>
              <.link
                navigate={~p"/users/settings"}
                class="px-5 py-2.5 text-sm font-semibold rounded-2xl border-2 border-gray-200 text-gray-700 hover:border-gray-300 hover:bg-gray-50 transition-all duration-300 hover:scale-105 transform shadow-sm inline-flex items-center gap-2"
              >
                <.icon name="hero-user-circle" class="w-5 h-5" />
                Profile
              </.link>
              <.link
                navigate={~p"/admin"}
                class="group relative px-5 py-2.5 text-sm font-semibold rounded-2xl bg-gradient-to-r from-gray-900 to-gray-800 text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 transform overflow-hidden"
              >
                <span class="absolute inset-0 bg-gradient-to-r from-blue-600 to-purple-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
                <span class="relative">Dashboard</span>
              </.link>
              <.link
                href={~p"/users/log-out"}
                method="delete"
                class="px-5 py-2.5 text-sm font-semibold rounded-2xl border-2 border-gray-200 text-gray-700 hover:border-gray-300 hover:bg-gray-50 transition-all duration-300 hover:scale-105 transform shadow-sm"
              >
                Log out
              </.link>
            <% else %>
              <.link
                navigate={~p"/users/log-in"}
                class="px-5 py-2.5 text-sm font-semibold rounded-2xl border-2 border-gray-200 text-gray-700 hover:border-gray-300 hover:bg-gray-50 transition-all duration-300 hover:scale-105 transform shadow-sm"
              >
                Log in
              </.link>
              <.link
                navigate={~p"/users/register"}
                class="group relative px-5 py-2.5 text-sm font-semibold rounded-2xl bg-gradient-to-r from-gray-900 to-gray-800 text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 transform overflow-hidden"
              >
                <span class="absolute inset-0 bg-gradient-to-r from-blue-600 to-purple-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
                <span class="relative">Get started</span>
              </.link>
            <% end %>
          </div>

          <div class="md:hidden">
            <button
              type="button"
              class="p-2.5 rounded-xl hover:bg-gray-100 transition-colors duration-200 active:scale-95 transform"
              aria-label="Open menu"
              phx-click={
                JS.toggle(
                  to: "#mobile-menu",
                  in:
                    {"transition ease-out duration-200", "opacity-0 -translate-y-2",
                     "opacity-100 translate-y-0"},
                  out:
                    {"transition ease-in duration-150", "opacity-100 translate-y-0",
                     "opacity-0 -translate-y-2"}
                )
              }
            >
              <.icon name="hero-bars-3" class="w-6 h-6 text-gray-700" />
            </button>
          </div>
        </div>
        <div id="mobile-menu" class="md:hidden hidden border-t border-gray-200 bg-white/95 backdrop-blur-md">
          <div class="px-4 py-4 space-y-4">
            <nav class="space-y-3">
              <a
                href="#download"
                class="block py-2.5 text-gray-700 font-medium hover:text-gray-900 transition-colors duration-200 rounded-lg hover:bg-gray-50 px-2"
              >
                Download
              </a>
              <a
                href="#pricing"
                class="block py-2.5 text-gray-700 font-medium hover:text-gray-900 transition-colors duration-200 rounded-lg hover:bg-gray-50 px-2"
              >
                Pricing
              </a>
            </nav>
            <div class="pt-2 flex flex-col gap-2 border-t border-gray-200">
              <%= if @current_scope && @current_scope.user do %>
                <.link
                  navigate={~p"/users/settings"}
                  class="w-full px-4 py-3 text-sm font-semibold rounded-2xl border-2 border-gray-200 text-gray-700 text-center hover:border-gray-300 hover:bg-gray-50 transition-all duration-300 active:scale-95 transform inline-flex items-center justify-center gap-2"
                >
                  <.icon name="hero-user-circle" class="w-5 h-5" />
                  Profile
                </.link>
                <.link
                  navigate={~p"/admin"}
                  class="w-full px-4 py-3 text-sm font-semibold rounded-2xl bg-gradient-to-r from-gray-900 to-gray-800 text-white text-center shadow-lg transition-all duration-300 active:scale-95 transform"
                >
                  Dashboard
                </.link>
                <.link
                  href={~p"/users/log-out"}
                  method="delete"
                  class="w-full px-4 py-3 text-sm font-semibold rounded-2xl border-2 border-gray-200 text-gray-700 text-center hover:border-gray-300 hover:bg-gray-50 transition-all duration-300 active:scale-95 transform"
                >
                  Log out
                </.link>
              <% else %>
                <.link
                  navigate={~p"/users/log-in"}
                  class="w-full px-4 py-3 text-sm font-semibold rounded-2xl border-2 border-gray-200 text-gray-700 text-center hover:border-gray-300 hover:bg-gray-50 transition-all duration-300 active:scale-95 transform"
                >
                  Log in
                </.link>
                <.link
                  navigate={~p"/users/register"}
                  class="w-full px-4 py-3 text-sm font-semibold rounded-2xl bg-gradient-to-r from-gray-900 to-gray-800 text-white text-center shadow-lg transition-all duration-300 active:scale-95 transform"
                >
                  Get started
                </.link>
              <% end %>
            </div>
          </div>
        </div>
      </header>
      <div class="mx-auto max-w-7xl">
        {render_slot(@inner_block)}
      </div>
    </main>
    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
