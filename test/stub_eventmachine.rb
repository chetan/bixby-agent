
module EventMachine
  class << self

    alias_method :_orig_run, :run
    alias_method :_orig_next_tick, :next_tick
    alias_method :_orig_stop, :stop
    alias_method :_orig_stop_event_loop, :stop_event_loop

    def run_immediately(&block)
      @reactor_running = true
      block.call() if block
    end

    def tick_immediately(&block)
      block.call() if block
    end

    def noop
    end

    def stub!
      define_singleton_method :run, method(:run_immediately)
      define_singleton_method :next_tick, method(:tick_immediately)
      define_singleton_method :stop, method(:noop)
      define_singleton_method :stop_event_loop, method(:noop)
    end

    def disable_stub!
      define_singleton_method :run, method(:_orig_run)
      define_singleton_method :next_tick, method(:_orig_next_tick)
      define_singleton_method :stop, method(:_orig_stop)
      define_singleton_method :stop_event_loop, method(:_orig_stop_event_loop)
    end

  end
end

