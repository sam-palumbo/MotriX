require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "#brl" do
    it "formats nil as R$ 0,00" do
      expect(helper.brl(nil)).to eq("R$ 0,00")
    end

    it "formats integer as currency" do
      expect(helper.brl(10)).to eq("R$ 10,00")
    end

    it "formats floats with precision" do
      expect(helper.brl(1234.56)).to eq("R$ 1.234,56")
    end
  end

  describe "#enum_label" do
    it "humanizes string values" do
      expect(helper.enum_label("pagamento_semanal")).to eq("Pagamento semanal")
    end

    it "humanizes symbol values" do
      expect(helper.enum_label(:rendimento_socio)).to eq("Rendimento socio")
    end
  end
  
  describe "#flash_alert_class" do
    it "maps notice to green" do
      expect(helper.flash_alert_class(:notice)).to eq("green")
    end
    
    it "maps alert to red" do
      expect(helper.flash_alert_class(:alert)).to eq("red")
    end
  end

  describe "#icon" do
    it "renders a span with the correct emoji" do
      html = helper.icon("cloud-upload")
      expect(html).to include("☁️")
      expect(html).to include("font-size: 16px")
    end

    it "accepts custom size" do
      html = helper.icon("paperclip", size: 24)
      expect(html).to include("📎")
      expect(html).to include("font-size: 24px")
    end
  end
end
