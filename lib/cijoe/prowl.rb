class CIJoe
  module Prowl
    def self.activate
      if valid_config?
        require 'prowl'

        if ::Prowl.verify(config[:apikey])
          CIJoe::Build.class_eval do
            include CIJoe::Prowl
          end
          
          puts "Loaded Prowl notifier"
        else
          puts "Prowl API key invalid"
        end
      else
        puts "Can't load Prowl notifier."
        puts "Please add the following to your project's .git/config:"
        puts "[prowl]"
        puts "\tapikey = abc123def456"
        puts "\tevent = \"Build Finished\""
      end
    end

    def self.config
      @config ||= {
        :apikey  => Config.prowl.apikey.to_s,
        :event    => Config.prowl.event.to_s
      }
    end

    def self.valid_config?
      %w( apikey event ).all? do |key|
        !config[key.intern].empty?
      end
    end

    def notify
      puts ""
      ::Prowl.add(
                  :apikey => Prowl.config[:apikey],
                  :application => "CI Joe",
                  :event => Prowl.config[:event],
                  :description => "#{short_message}"
                )
      #room.speak "#{short_message}. #{commit.url}"
      #room.paste full_message if failed?
    end

  private
    def short_message
      "Build #{short_sha} of #{project} #{worked? ? "was successful" : "failed"}"
    end

    def full_message
      <<-EOM
Commit Message: #{commit.message}
Commit Date: #{commit.committed_at}
Commit Author: #{commit.author}

#{clean_output}
EOM
    end
  end
end
