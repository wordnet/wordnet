module ProgressBarExporter
  def export!(*args, &block)
    @progress_bar = ProgressBar.create(
      :title => self.class.name.split('::').last,
      :total => @pages,
      :format => "%t: |%B| %c/%C %E",
      :smoothing => 0.8
    )

    super(*args, &block)
  end

  def export_entities!(*args, &block)
    super(*args, &block)
    @progress_bar.increment
  end
end
