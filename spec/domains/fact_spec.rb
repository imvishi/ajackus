require "rails_helper"

RSpec.describe Fact do
  let(:fact_class) { Voting::Events::EventUpvoted }

  it "builds the event when data matches the schema" do
    fact = fact_class.strict(data: { event_id: 1, user_id: "user_1" })

    expect(fact.data).to eq(event_id: 1, user_id: "user_1")
  end

  it "rejects a missing field" do
    expect { fact_class.strict(data: { event_id: 1 }) }.to raise_error(ArgumentError)
  end

  it "rejects an extra field" do
    expect { fact_class.strict(data: { event_id: 1, user_id: "user_1", extra: 1 }) }.to raise_error(ArgumentError)
  end

  it "rejects a wrong type" do
    expect { fact_class.strict(data: { event_id: "1", user_id: "user_1" }) }.to raise_error(ArgumentError)
  end
end
