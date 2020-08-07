require 'aerospike'
require 'active_support'

module ActiveSupport
  module Cache
    class AerospikeStore < Store

    AEROSPIKE_DEFAULT_OPTIONS = {
      :host => '127.0.0.1',
      :port => 3000,
      :ns   => 'test',
      :set  => 'cache',
      :bin  => 'entry'
    }

    def initialize(options = {})
      options.merge!(self.class::AEROSPIKE_DEFAULT_OPTIONS) { |key, v1, v2| v1 }
      @client = options.delete(:client) || Aerospike::Client.new(options.delete(:host), options.delete(:port))
      super
    end

    def increment(name, amount = 1, options = nil)
      options = merged_options(options)
      instrument(:increment, name, :amount => amount) do
        key = namespaced_key(name, options)
        @client.add(as_key(key, options), {options[:bin] => amount}, options)
      end
    end

    def decrement(name, amount = 1, options = nil)
      options = merged_options(options)
      instrument(:decrement, name, :amount => amount) do
        key = namespaced_key(name, options)
        @client.add(as_key(key, options), {options[:bin] => -1 * amount}, options)
      end
    end

    protected
      def internal_read_entry(key, options)
        record = @client.get(as_key(key, options))
        if record 
          # single-bin namespaces do not return a bin name
          (record.bins.length == 1)? record.bins.values.first : record.bins[options[:bin]]
        else
          nil
        end
      end

      def read_entry(key, options)
        if value = internal_read_entry(key, options)
          # if it is not raw it is a marshalled ActiveSupport::Cache::Entry
          value = options[:raw]? ActiveSupport::Cache::Entry.new(value) : Marshal.load(value)
        else
          nil
        end
      end

      def write_entry(key, entry, options)
        return false if entry.value.nil? && !options[:cache_nils]

        options[:expiration] ||= options[:expires_in] if options[:expires_in]
        options[:record_exists_action] ||= options[:unless_exist]? Aerospike::RecordExistsAction::CREATE_ONLY : Aerospike::RecordExistsAction::REPLACE
        value = options[:raw]? entry.value : Marshal.dump(entry)
        begin
          @client.put(as_key(key, options), {options[:bin] => value}, options)
        rescue Aerospike::Exceptions::Aerospike => e
          raise unless (e.result_code == Aerospike::ResultCode::KEY_EXISTS_ERROR)
          false
        end
      end

      def delete_entry(key, options)
        @client.delete(as_key(key, options))
      end

    private
      def as_key(key, options)
        Aerospike::Key.new(options[:ns], options[:set], key)
      end

    end # class AerospikeStore
  end
end
