# frozen_string_literal: true

RSpec.describe RequestStore::Fibers do
  it "has a version number" do
    expect(RequestStore::Fibers::VERSION).not_to be nil
  end

  describe "#init" do
    it "passes RequestStore thread-locals to child fibers" do
      RequestStore::Fibers.init
      RequestStore.store = { donald: "duck" }
      result = Fiber.new { RequestStore.store[:donald] }.resume
      expect(result).to eq("duck")
    ensure
      RequestStore::Fibers.uninit
    end
  end

  describe "#uninit" do
    it "no longer passes RequestStore thread-locals to child fibers" do
      RequestStore::Fibers.init
      RequestStore::Fibers.uninit
      RequestStore.store = { donald: "duck" }
      result = Fiber.new { RequestStore.store[:donald] }.resume
      expect(result).to be_nil
    end
  end
end
