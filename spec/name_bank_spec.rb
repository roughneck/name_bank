# frozen_string_literal: true

require "spec_helper"

RSpec.describe NameBank do
  it "has a version" do
    expect(NameBank::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
