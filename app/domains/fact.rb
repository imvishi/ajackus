# Base class for domain events. Subclasses define SCHEMA (attribute => type).
class Fact < RubyEventStore::Event
  # Builds the event only if data has exactly the SCHEMA keys with the right types.
  def self.strict(data:)
    valid = data.keys.sort == self::SCHEMA.keys.sort &&
            self::SCHEMA.all? { |key, type| data[key].is_a?(type) }
    raise ArgumentError, "#{name}: invalid data #{data.inspect}" unless valid

    new(data:)
  end
end
