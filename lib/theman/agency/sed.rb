module Sed
  extend ActiveSupport::Concern

  module InstanceMethods
    # custom seds to parse stream with
    def seds(*args)
      @seds = args
    end

    def chop(line = 1)
      @chop = line
    end
      
    def sed_command(sed = []) #:nodoc:
      sed << nulls_to_sed unless @nulls.nil?
      sed << @seds unless @seds.nil?
      sed << chop_to_sed unless @chop.nil?
      sed
    end

    def chop_to_sed #:nodoc:
      "-n -e :a -e '1,#{@chop}!{P;N;D;};N;ba'"
    end

    def nulls_to_sed #:nodoc:
      @nulls.map do |regex|
        "-e 's/#{regex.source}//g'"
      end
    end
  end
end
