defmodule AnalyticsClient do

  def increment_message do
    DistributedClient.call({:global, Analytics.Messaging.Server}, :message_received, 50)
  end
end
