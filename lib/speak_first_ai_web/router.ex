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

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpeakFirstAiWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", SpeakFirstAiWeb do
  #   pipe_through :api
  # end

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
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SpeakFirstAiWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", SpeakFirstAiWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{SpeakFirstAiWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  scope "/admin", SpeakFirstAiWeb do
    pipe_through [:browser , :require_authenticated_user]

    ## Admin Dashboard
    live "/", AdminDashboardLive, :index

    ## Coaching Personas
    live "/coaching_personas", CoachingPersonaLive.Index, :index
    live "/coaching_personas/new", CoachingPersonaLive.Index, :new
    live "/coaching_personas/:id/edit", CoachingPersonaLive.Index, :edit

    live "/coaching_personas/:id", CoachingPersonaLive.Show, :show
    live "/coaching_personas/:id/show/edit", CoachingPersonaLive.Show, :edit

    ## Conversation Topics
    live "/conversation_topics", ConversationTopicLive.Index, :index
    live "/conversation_topics/new", ConversationTopicLive.Index, :new
    live "/conversation_topics/:id/edit", ConversationTopicLive.Index, :edit

    live "/conversation_topics/:id", ConversationTopicLive.Show, :show
    live "/conversation_topics/:id/show/edit", ConversationTopicLive.Show, :edit

    ## Lessons
    live "/lessons", LessonLive.Index, :index
    live "/lessons/new", LessonLive.Index, :new
    live "/lessons/:id/edit", LessonLive.Index, :edit

    live "/lessons/:id", LessonLive.Show, :show
    live "/lessons/:id/show/edit", LessonLive.Show, :edit

    ## Subscription Plans
    live "/subscription_plans", SubscriptionPlanLive.Index, :index
    live "/subscription_plans/new", SubscriptionPlanLive.Index, :new
    live "/subscription_plans/:id/edit", SubscriptionPlanLive.Index, :edit

    live "/subscription_plans/:id", SubscriptionPlanLive.Show, :show
    live "/subscription_plans/:id/show/edit", SubscriptionPlanLive.Show, :edit
  end

end
