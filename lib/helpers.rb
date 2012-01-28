module Helpers
  def partial(name, opts={})
    haml name, opts.merge(:layout => false)
  end
end