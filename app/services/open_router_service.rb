# frozen_string_literal: true

class OpenRouterService
  # Custom Error classes
  class ApiError < StandardError
    attr_reader :details

    def initialize(message = nil, details: {})
      super(message)
      @details = details
    end
  end

  class ClientError < ApiError; end       # 4xx errors
  class ServerError < ApiError; end       # 5xx errors
  class ConnectionError < ApiError; end   # Network errors
  class TimeoutError < ApiError; end      # Timeout errors
  class UnexpectedError < ApiError; end   # Other errors

  # Public attributes (read-only)
  attr_reader :system_message, :model_name, :model_params

  # Public methods
  def initialize(system_message: "System: You are a helpful and precise assistant.",
                 model_name: "gpt-4o-mini",
                 model_params: { temperature: 0.7, max_tokens: 512, top_p: 1.0, frequency_penalty: 0, presence_penalty: 0 },
                 api_endpoint: "https://openrouter.ai/api/v1", # Base URL for the API
                 retry_policy: { max: 2, interval: 0.5, backoff_factor: 2 })
    @system_message = system_message
    @model_name = model_name
    @model_params = model_params
    @api_endpoint = api_endpoint
    @retry_policy = retry_policy
    @api_key = Rails.application.credentials.open_router_api_key

    # Initialize Faraday connection
    @connection = Faraday.new(url: @api_endpoint) do |faraday|
      faraday.request :authorization, "Bearer", @api_key
      faraday.request :json # Encode request body as JSON and set Content-Type

      faraday.response :json # Decode response body as JSON
      faraday.response :raise_error # Raise exceptions for 4xx/5xx responses
      faraday.response :logger, Rails.logger # Log requests and responses using Rails logger
      faraday.adapter Faraday.default_adapter # Use the default adapter (e.g., Net::HTTP)
    end

    # Initialize variable to store the last response
    @last_response = nil
  end

  # Sends a user message to the API
  # Returns the processed response or raises a custom API error on failure
  def send_chat_message(user_message:)
    @user_message = user_message # Store the last user message
    payload = prepare_payload(message: @user_message)

    begin
      # Make POST request to the chat completions endpoint
      api_response = @connection.post("chat/completions") do |req|
        req.body = payload
      end
      @last_response = transform_response(api_response: api_response.body)
    rescue Faraday::Error => e
      handle_error(e) # Delegate Faraday errors to the handler method
    rescue StandardError => e # Catch other potential non-Faraday errors
      Rails.logger.error("OpenRouterService Unexpected Error: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}")
      raise UnexpectedError, "An unexpected error occurred: #{e.message}"
    end
    @last_response # Return the stored response
  end

  # Retrieves the last processed response
  def get_chat_response
    @last_response || { response: "No response yet." } # Return last response or default
  end

  # Allows dynamic configuration of API and model settings
  def configure_api(config: {})
    if config.key?(:system_message)
      unless config[:system_message].is_a?(String)
        Rails.logger.warn("Invalid type for system_message configuration: Expected String, got #{config[:system_message].class}")
      end
      @system_message = config[:system_message].to_s # Attempt to convert just in case
    end

    if config.key?(:model_name)
      unless config[:model_name].is_a?(String)
        Rails.logger.warn("Invalid type for model_name configuration: Expected String, got #{config[:model_name].class}")
      end
      @model_name = config[:model_name].to_s
    end

    if config.key?(:model_params)
      unless config[:model_params].is_a?(Hash)
        Rails.logger.warn("Invalid type for model_params configuration: Expected Hash, got #{config[:model_params].class}")
      else
        @model_params.merge!(config[:model_params])
      end
    end

    # Re-initializing the connection might be needed if endpoint/auth changes
    Rails.logger.info("OpenRouterService configured with: #{config}")
  end

  private

  # Prepares the payload for the API request
  def prepare_payload(message:)
    {
      model: @model_name,
      messages: [
        { role: "system", content: @system_message },
        { role: "user", content: message }
      ]
    }.merge(@model_params) # Merge with model parameters like temperature, max_tokens
  end

  # Transforms the raw API response into the desired format { response: content }
  def transform_response(api_response:)
    # Use safe navigation (&.) in case parts of the response are missing
    content = api_response&.dig("choices", 0, "message", "content")

    # Basic validation/check if content was found
    unless content
      Rails.logger.warn("Could not parse response content from API response: #{api_response.inspect}")
      # Return a structured error response instead of raising immediately
      # Calling code can check for `response.nil?` or specific error content
      return { response: nil, error: "Could not parse response content." }
    end

    { response: content }
  end

  # Central error handling mechanism for Faraday errors
  def handle_error(error)
    log_message = "OpenRouter API Error: #{error.class} - #{error.message}"
    error_details = {}
    error_class = UnexpectedError # Default error class
    error_msg_prefix = "Unexpected API Error:"

    if error.is_a?(Faraday::ClientError) && error.response
      status = error.response[:status]
      body = error.response[:body]
      log_message << "\nStatus: #{status}\nBody: #{body}"
      error_details = { status: status, body: body }
      error_class = ClientError
      error_msg_prefix = "Client Error: Status #{status}."

    elsif error.is_a?(Faraday::ServerError) && error.response
      status = error.response[:status]
      body = error.response[:body]
      log_message << "\nStatus: #{status}\nBody: #{body}"
      error_details = { status: status, body: body }
      error_class = ServerError
      error_msg_prefix = "Server Error: Status #{status}."

    elsif error.is_a?(Faraday::ConnectionFailed)
      log_message << "\nCheck network connectivity and API endpoint."
      error_class = ConnectionError
      error_msg_prefix = "Connection Failed:"

    elsif error.is_a?(Faraday::TimeoutError)
      log_message << "\nRequest timed out."
      error_class = TimeoutError
      error_msg_prefix = "Request Timeout:"

    else
      log_message << "\nUnexpected Faraday error occurred."
    end

    Rails.logger.error(log_message)
    # Raise the determined error class with a formatted message and details
    raise error_class.new("#{error_msg_prefix} #{error.message}", details: error_details)
  end
end
