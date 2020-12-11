# lib/join_keys.rb

module ApiBlocks
  module Blueprinter
    class JoinKeys
      # Based on https://github.com/MaxLap/activerecord_where_assoc/blob/100318de80dea5f3c177526c3f824fda307ebc04/lib/active_record_where_assoc/active_record_compat.rb
      if ActiveRecord.gem_version >= Gem::Version.new("6.1.0.rc1")
        JoinKeys = Struct.new(:key, :foreign_key)
        def self.join_keys(reflection)
          JoinKeys.new(reflection.join_primary_key, reflection.join_foreign_key)
        end

      elsif ActiveRecord.gem_version >= Gem::Version.new("5.1")
        def self.join_keys(reflection)
          reflection.join_keys
        end
      end
    end
  end
end
