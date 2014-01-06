module ThreadPoolImporter
  def import!(*args, &block)
    @thread_pool = Thread::Pool.new(2)
    super(*args, &block)
    @thread_pool.shutdown
  end

  def import_entities!(*args, &block)
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
