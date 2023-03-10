require 'rails_helper'
require 'huginn_agent/spec_helper'

describe Agents::KafkaProducerAgent do
  before(:each) do
    @valid_options = Agents::KafkaProducerAgent.new.default_options
    @checker = Agents::KafkaProducerAgent.new(:name => "KafkaProducerAgent", :options => @valid_options)
    @checker.user = users(:bob)
    @checker.save!
  end

  pending "add specs here"
end
