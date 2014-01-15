module SynchronizedWriteExporter
  def export!(*args, &block)
    @mutex = Mutex.new
    super(*args, &block)
  end

  def persist_entities!(*args, &block)
    @mutex.synchronize do
      super(*args, &block)
    end
  end
end
