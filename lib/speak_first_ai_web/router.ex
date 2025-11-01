defmodule SpeakFirstAiWeb.Router do
  use SpeakFirstAiWeb, :router

  import SpeakFirstAiWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SpeakFirstAiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :admin do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug SpeakFirstAiWeb.Plugs.CurrentPath
    plug :put_root_layout, html: {SpeakFirstAiWeb.Layouts, :admin}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpeakFirstAiWeb do
    pipe_through :browser
    # No default route here - landing page is in live_session :current_user below
  end

  scope "/webhooks", SpeakFirstAiWeb do
    pipe_through :api

    post "/stripe", StripeWebhookController, :create
  end

  scope "/api", SpeakFirstAiWeb do
    pipe_through :api

    post "/auth/register", ApiAuthController, :register
    post "/auth/login", ApiAuthController, :login
    post "/auth/refresh", ApiAuthController, :refresh
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:speak_first_ai, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SpeakFirstAiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SpeakFirstAiWeb do
    pipe_through :admin

    live_session :require_authenticated_user,
      on_mount: [
        {SpeakFirstAiWeb.UserAuth, :require_authenticated},
        {SpeakFirstAiWeb.LiveAdminHooks, :assign_current_path}
      ] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

      ## Admin Dashboard
      live "/admin", AdminDashboardLive, :index

      ## Coaching Personas
      live "/admin/coaching_personas", CoachingPersonaLive.Index, :index
      live "/admin/coaching_personas/new", CoachingPersonaLive.Form, :new
      live "/admin/coaching_personas/:id/edit", CoachingPersonaLive.Form, :edit

      live "/admin/coaching_personas/:id", CoachingPersonaLive.Show, :show
      live "/admin/coaching_personas/:id/show/edit", CoachingPersonaLive.Form, :edit

      ## Conversation Topics
      live "/admin/conversation_topics", ConversationTopicLive.Index, :index
      live "/admin/conversation_topics/new", ConversationTopicLive.Form, :new
      live "/admin/conversation_topics/:id/edit", ConversationTopicLive.Form, :edit

      live "/admin/conversation_topics/:id", ConversationTopicLive.Show, :show
      live "/admin/conversation_topics/:id/show/edit", ConversationTopicLive.Form, :edit

      ## Lessons
      live "/admin/lessons", LessonLive.Index, :index
      live "/admin/lessons/new", LessonLive.Form, :new
      live "/admin/lessons/:id/edit", LessonLive.Form, :edit

      live "/admin/lessons/:id", LessonLive.Show, :show
      live "/admin/lessons/:id/show/edit", LessonLive.Form, :edit

      ## Subscription Plans
      live "/admin/subscription_plans", SubscriptionPlanLive.Index, :index
      live "/admin/subscription_plans/new", SubscriptionPlanLive.Form, :new
      live "/admin/subscription_plans/:id/edit", SubscriptionPlanLive.Form, :edit

      live "/admin/subscription_plans/:id", SubscriptionPlanLive.Show, :show
      live "/admin/subscription_plans/:id/show/edit", SubscriptionPlanLive.Form, :edit
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", SpeakFirstAiWeb do
    pipe_through :browser

    # Subscription routes
    get "/subscriptions", SubscriptionController, :show
    post "/subscriptions", SubscriptionController, :create
    post "/subscriptions/cancel", SubscriptionController, :cancel_subscription
    post "/subscriptions/refund", SubscriptionController, :request_refund
    post "/subscriptions/upgrade", SubscriptionController, :upgrade
    post "/subscriptions/payment_method", SubscriptionController, :update_payment_method
    get "/subscriptions/success", SubscriptionController, :success
    get "/subscriptions/cancel", SubscriptionController, :cancel
  end

  scope "/", SpeakFirstAiWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{SpeakFirstAiWeb.UserAuth, :mount_current_scope}] do
      # Landing page - works with or without authentication
      live "/", LandingLive, :index

      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
