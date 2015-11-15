class MaybeClient
  DELAY = 60

  def initialize(client_class, *connect_params)
    @connect_params = connect_params
    @client_class = client_class

    initialize_client
  end

  def respond_to? method
    !!@client && @client.respond_to?(method)
  end

  # Used to delegate everything to @client
  def method_missing(method, *args, &block)
    return if noop?
    initialize_client unless @client
    return if noop?

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
    @fail_at && @fail_at + DELAY > Time.now
  end

  def handle_exception(e)
    @fail_at = Time.now
  end

  def initialize_client
    begin
      @client = @client_class.new(*@connect_params)
    rescue Exception => e
      handle_exception(e)
    end
  end
end
