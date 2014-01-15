module ThreadPoolExporter
  def export!(*args, &block)
    @thread_pool = Thread::Pool.new(2)
    super(*args, &block)
    @thread_pool.shutdown
  end

  def export_entities!(*args, &block)
    @thread_pool.process do
      begin
        super(*args, &block)
      rescue Exception => e
        puts e.message
        raise
      end
    end
  end
end
