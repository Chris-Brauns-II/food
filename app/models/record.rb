module Record
  def schema(&)
    include(ValueSemantics.for_attributes(&))
  end
end
