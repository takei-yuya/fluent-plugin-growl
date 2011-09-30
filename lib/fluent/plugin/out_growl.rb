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

		def initialize
			@growl
		end

		def configure(conf)
			server = conf['server'] || DEFAULT_SERVER
			password = conf['password'] || DEFAULT_PASSWORD
			appname = conf['appname'] || DEFAULT_APPNAME

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
				@notifies[name] = {:priority => priority, :sticky => sticky}
			}
			# if @notifies.empty?
			#  raise ConfigError, "At least one <notify> directive is needed"
			# end
			@notifies[DEFAULT_NOTIFICATION_NAME] = {:priority => 0, :sticky => false}

			@growl = Growl.new server, appname, @notifies.keys, nil, password
		end

		def emit(tag, es, chain)
			es.each{|e|
				title = e.record["title"] || "Fluent Notification"
				message = e.record["message"] || "#{e.record.to_json} at #{Time.at(e.time).localtime}"
				notifyname = e.record["notify"] || DEFAULT_NOTIFICATION_NAME
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
