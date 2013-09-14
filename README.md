ohm-stateful-model
==================

Integrate state machines (from the state_machine gem) into your Ohm models.

### Setup

Require the gem:

```ruby
require 'ohm/stateful_model'
```

Define your state machine and inherit from `Ohm::State`:

```ruby
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
```

Define your Ohm model by inheriting from `Ohm::StatefulModel`.  Specify the state machine to use via the `use_state_machine` class method.

```ruby
class Vehicle < Ohm::StatefulModel
  use_state_machine VehicleState
end
```

You can specify an optional `:attribute_name` flag to be used as the state's model attribute.  By default, the name of the state machine is used:

```ruby
class Vehicle < Ohm::StatefulModel
  use_state_machine VehicleState, :attribute_name => :my_state
end
```

### Usage

Once your state machine has been integrated into your model, you will be able to interact with it as if it were a model attribute.  You will also be able to transition between states, persist the current state along with the rest of the model, and call any `StateMachine::Machine` methods:

```ruby
v = Vehicle.new
v.state             # => "parked"

v.can_start_car?    # => true
v.start_car
v.state             # => "idling"
v.idling?           # => true
v.can_start_car?    # => false

v.new?              # => true
v.save
v.new?              # => false

# fetch persisted data
v2 = Vehicle[v.id]
v2.state            # => "idling"
v2.idling?          # true

v2.can_park?         # => true
v2.park
v2.parked?           # => true
v2.save
```

### Requirements

ohm-stateful-model depends on the ohm gem, which requires a running redis instance.

### Running Tests

`bundle exec rspec`

### Authors

* Cameron C. Dutro: http://github.com/camertron

### Links

* state_machine gem: [https://github.com/pluginaweek/state_machine](https://github.com/pluginaweek/state_machine)
* ohm gem: [https://github.com/soveran/ohm](https://github.com/soveran/ohm)

### License

Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
