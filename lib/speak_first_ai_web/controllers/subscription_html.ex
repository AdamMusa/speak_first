defmodule SpeakFirstAiWeb.SubscriptionHTML do
  @moduledoc """
  This module contains pages rendered by SubscriptionController.

  See the `subscription_html` directory for all templates available.
  """
  use SpeakFirstAiWeb, :html

  embed_templates "subscription_html/*"
end
