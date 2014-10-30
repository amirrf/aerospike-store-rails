require 'active_support/cache'
require 'action_dispatch/middleware/session/abstract_store'
require 'aerospike'

module ActionDispatch
	module Session
		class AerospikeStore < AbstractStore

	    AEROSPIKE_DEFAULT_OPTIONS = {
	      :host => '127.0.0.1',
	      :port => 3000,
	      :ns   => 'test',
	      :set  => 'session',
	      :bin  => 'data'
	    }

			def initialize(app, options = {})
	      options.merge!(self.class::AEROSPIKE_DEFAULT_OPTIONS) { |key, v1, v2| v1 }
	      @client = options.delete(:client) || Aerospike::Client.new(options.delete(:host), options.delete(:port))
				super
			end

		  private

			def generate_sid
				loop do
					sid = super
					break sid unless @client.exists(as_key(sid))
				end
			end

			def internal_get_session(sid)
				record = @client.get(as_key(sid))
				if record 
					# single-bin namespaces do not return a bin name
					(record.bins.length == 1)? record.bins.values.first : record.bins[@default_options[:bin]]
				else
					nil
				end
			end

			def get_session(env, sid)
				unless sid and session = internal_get_session(sid)
					sid, session = generate_sid, {}
				end
				[sid, session]
			end

			def set_session(env, sid, session, options)
				opt = {:send_key => false}
				opt[:expiration] = options[:expire_after] if options[:expire_after]
				@client.put(as_key(sid), Aerospike::Bin.new(@default_options[:bin], session), opt)
				sid
			end

			def destroy_session(env, sid, options)
				@client.delete(as_key(sid))
				generate_sid unless options[:drop]
			end

			def as_key(sid)
				Aerospike::Key.new(@default_options[:ns], @default_options[:set], sid)
			end
		
		end # class AerospikeStore
	end
end