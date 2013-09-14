# encoding: UTF-8

require 'ohm'
require 'state_machine'

module Ohm
  class StatefulModel < Ohm::Model

    class << self

      attr_reader :state_machine_class, :state_machine_name

      def use_state_machine(state_machine_class, options = {})
        if @state_machine_class
          raise "A state machine is already in use for this model"
        else
          if state_machine_class.ancestors.include?(Ohm::State)
            @state_machine_class = state_machine_class
            @state_machine_name = options[:attribute_name]
          else
            raise "#{state_machine_class} must inherit from Ohm::State"
          end
        end
      end

    end

    attr_reader :state_machine

    def initialize(*args)
      if self.class.state_machine_class
        @state_machine = self.class.state_machine_class.new

        # define Ohm::Model attribute
        self.class.attribute(state_machine_name)

        # override state setting method so it updates both the attributes hash
        # and the state machine's state
        define_singleton_method(:"#{state_machine_name}=") do |new_state|
          @attributes[state_machine_name] = new_state
          @state_machine.state = new_state
        end

        # hook every transition so we can update the attributes hash
        @state_machine.after_transition_proc = lambda do |obj, transition|
          update_attributes(state_machine_name => obj.state)
        end

        super
        initialize_value
      else
        super
      end
    end

    def respond_to_missing?(method)
      @state_machine.respond_to?(method)
    end

    def method_missing(method, *args, &block)
      if @state_machine.respond_to?(method)
        @state_machine.send(method, *args, &block)
      else
        raise NoMethodError.new("undefined method `#{method}' for #{self.class.name}")
      end
    end

    private

    def initialize_value
      get(state_machine_name) unless new?
      val = @attributes[state_machine_name]

      if @state_machine.class.state_machine.states.keys.include?(val)
        @state_machine.state = val
      else
        @attributes[state_machine_name] = @state_machine.state
      end
    end

    def state_machine_name
      self.class.state_machine_name || @state_machine.class.state_machine.name
    end

  end

  class State

    attr_accessor :after_transition_proc

    class << self

      alias_method :state_machine_without_additions, :state_machine

      def state_machine(*args, &block)
        if block
          state_machine_without_additions(*args, &block).tap do |machine|
            add_callbacks_to(machine)
          end
        else
          state_machine_without_additions(*args)
        end
      end

      def add_callbacks_to(obj)
        obj.instance_eval do
          after_transition do |obj, transition|
            if obj.after_transition_proc
              obj.after_transition_proc.call(obj, transition)
            end
          end
        end
      end

    end

  end
end