class MaybeClient
  DELAY = 60

  def initialize(client: nil, client_class: nil, connect_params: nil)
    @client = client
    @connect_params = connect_params
    @client_class = client_class
    @should_initialize = !!@client_class

    initialize_client if client_initialization_needed?
  end

  def respond_to? method
    !!@client && @client.respond_to?(method)
  end

  # Used to delegate everything to @client
  def method_missing(method, *args, &block)
    return if noop?
    initialize_client if client_initialization_needed?
    return if in_delay?

    # Raises NoMethodError
    super unless @client.respond_to? method

    result = nil

    begin
      @fail_at = nil
      result = @client.send(method, *args)
    rescue Exception => e
      handle_exception(e)
    end

    result
  end

  private
  def noop?
    no_client? || in_delay?
  end

  def no_client?
    !@client && !@should_initialize
  end

  def in_delay?
    @fail_at && @fail_at + DELAY > Time.now
  end

  def exception_handler(e)
  end

  def handle_exception(e)
    @fail_at = Time.now
    exception_handler(e)
  end

  def client_initialization_needed?
    !@client && @should_initialize
  end

  def initialize_client
    begin
      @client = @client_class.new(@connect_params)
    rescue Exception => e
      handle_exception(e)
    end
  end
end
