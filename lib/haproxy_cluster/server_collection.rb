class HAProxyCluster
  class ServerCollection < Array
    def find(string)
      self.select do |s|
        s.name == string
      end.first
    end
  end
end
