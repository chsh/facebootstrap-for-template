class ConfigOrEnv

  # alias for :value
  def self.[](key)
    self.value(key)
  end
  def self.value(key)
    @@instance ||= ConfigOrEnv.new
    @@instance.value(key)
  end

  def value(key)
    config_value(key) || env_value(key)
  end

  def config_value(key)
    keys = key.split('.')
    primary = keys.shift
    c = Configuration.for(primary)
    keys.each do |k|
      return nil unless c.respond_to? k
      c = c.send(k)
    end
    c
  end
  def env_value(key)
    ENV[key.tr('.', '_').upcase]
  end
end
