# encoding: UTF-8

require 'rspec'
require 'ohm/stateful_model'
require 'mock_redis'

module Ohm
  class Connection

    def redis
      threaded[context] ||= ::MockRedis.new
    end

  end
end

class VehicleState < Ohm::State

  state_machine :state, :initial => :parked do
    event :park do
      transition :idling => :parked
    end
  
    event :start_car do
      transition :parked => :idling
    end
  end

end

class Vehicle < Ohm::StatefulModel

  use_state_machine VehicleState

end
