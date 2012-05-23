module Mongoid
  module Document
    def as_json(options={})
      attrs = super(options)

      # If the model is peristed add an "id" key for compatability with spine
      attrs["id"] = self.persisted? ? self._id : nil

      # If a key is nil remove the key this allows the without criteria to hide fields
      attrs.delete_if {|key, value| value.nil? }
      
      attrs
    end
  end
end