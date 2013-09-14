# encoding: UTF-8

require 'spec_helper'

describe Ohm::StatefulModel do
  it "does not allow more than one state machine to be used" do
    lambda do
      Vehicle.class_eval do
        use_state_machine VehicleState
      end
    end.should raise_error("A state machine is already in use for this model")
  end

  it "requires state machines to inherit from Ohm::State" do
    lambda do
      model = Class.new(Ohm::StatefulModel) do
        FakeStateMachine = Class.new
        use_state_machine FakeStateMachine
      end
    end.should raise_error("FakeStateMachine must inherit from Ohm::State")
  end

  it "should allow assigning state on create" do
    vehicle = Vehicle.create(:state => "idling")
    vehicle.state.should == "idling"
    vehicle.state_machine.state.should == "idling"
    vehicle.can_park?.should be_true
  end

  context "with a model" do
    before(:each) do
      @vehicle = Vehicle.new
    end

    it "should have successfully defined the state on the model" do
      @vehicle.state.should == "parked"
      @vehicle.state_machine.state.should == "parked"
    end

    it "allows state assignment" do
      @vehicle.state = "idling"
      @vehicle.state.should == "idling"
      @vehicle.state_machine.state.should == "idling"
    end

    it "proxies state machine query methods" do
      @vehicle.can_start_car?.should be_true
      @vehicle.parked?.should be_true
    end

    it "allows changing state" do
      @vehicle.start_car
      @vehicle.state.should == "idling"
      @vehicle.idling?.should be_true
      @vehicle.park
      @vehicle.state.should == "parked"
      @vehicle.parked?.should be_true
    end

    context "and a persisted record" do
      before(:each) do
        @vehicle.save
      end

      it "persists the state along with the record" do
        vehicle = Vehicle[@vehicle.id]
        vehicle.state.should == "parked"
        vehicle.parked?.should be_true
      end

      it "persists changed state" do
        @vehicle.start_car
        @vehicle.state.should == "idling"
        @vehicle.idling?.should be_true
        @vehicle.save

        vehicle = Vehicle[@vehicle.id]
        vehicle.state.should == "idling"
        vehicle.idling?.should be_true
      end
    end
  end
end