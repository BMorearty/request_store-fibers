# frozen_string_literal: true

RSpec.describe RequestStore::Fibers do
  it "has a version number" do
    expect(RequestStore::Fibers::VERSION).not_to be nil
  end

  describe "#hook" do
    it "passes RequestStore thread-locals to child fibers" do
      RequestStore::Fibers.hook_up
      RequestStore.store = { donald: "duck" }
      result = Fiber.new { RequestStore.store[:donald] }.resume
      expect(result).to eq("duck")
    ensure
      RequestStore::Fibers.unhook
    end
  end

  describe "unhook" do
    it "no longer passes RequestStore thread-locals to child fibers" do
      RequestStore::Fibers.hook_up
      RequestStore::Fibers.unhook
      RequestStore.store = { donald: "duck" }
      result = Fiber.new { RequestStore.store[:donald] }.resume
      expect(result).to be_nil
    end
  end
end
