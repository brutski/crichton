class ::Hash
  def deep_merge(other)
    merger = ->(key, v1, v2) { 
      Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2
    }
    self.merge(other, &merger)
  end
end