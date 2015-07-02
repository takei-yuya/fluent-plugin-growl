# vim: set tw=0 sw=2 sts=2 ts=2 :

module Fluent
	require 'rubygems'
	require 'ruby-growl'

	class GrowlOutput < Output
		Plugin.register_output('growl', self);

		DEFAULT_SERVER = "localhost"
		DEFAULT_PASSWORD = nil
		DEFAULT_APPNAME = "Fluent Growl Notification"
		DEFAULT_NOTIFICATION_NAME = "Fluent Defalt Notification"
		DEFAULT_TITLE = "Fluent Notification"

		config_param :server, :string, :default => DEFAULT_SERVER
		config_param :password, :string, :default => DEFAULT_PASSWORD
		config_param :appname, :string, :default => DEFAULT_APPNAME

		def configure(conf)
			super

			@notifies = {}
			conf.elements.select{|e|
				e.name = "notify"
			}.each{|e|
				name = e['name']
				unless name
					raise ConfigError, "Missing 'name' parameter on <notify> directive"
				end
				priority = e['priority'].to_i
				sticky = (e.has_key? "sticky") && (e["sticky"].match /y(es)?|on|true/i ) && true
				@notifies[name] = { :priority => priority, :sticky => sticky }
			}
			# if @notifies.empty?
			#  raise ConfigError, "At least one <notify> directive is needed"
			# end
			@notifies[DEFAULT_NOTIFICATION_NAME] = { :priority => 0, :sticky => false }

			@growl = Growl.new @server, @appname
			@notifies.keys.each{|name|
				@growl.add_notification name
			}
			@growl.password = @password
		end

		def emit(tag, es, chain)
			es.each{|time,record|
				title = record["title"] || DEFAULT_TITLE
				message = record["message"] || "#{record.to_json} at #{Time.at(time).localtime}"
				notifyname = record["notify"] || DEFAULT_NOTIFICATION_NAME
				notify = @notifies[notifyname]
				unless notify
					# TODO: ConfigError?
					raise ConfigError, "Unknown notify name '#{notifyname}'"
				end

				@growl.notify notifyname, title, message, notify[:priority], notify[:sticky]
			}
			chain.next
		end

	end
end
