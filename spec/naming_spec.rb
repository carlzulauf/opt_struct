class WeirdNamesStruct < OptStruct.new(:FOO, :"123")
  options :Capitalized, :cameLized, :"⛔", :end, :for, :-, :"=", :"with space"
end

describe "naming" do
  subject { WeirdNamesStruct }

  it "allows all of the weird getter names to be called" do
    a = subject.new("bar", 456)
    expect(a.FOO).to eq("bar")
    expect(a.send("123")).to eq(456)
    expect(a.Capitalized).to be_nil
    expect(a.cameLized).to be_nil
    expect(a.⛔).to be_nil
    expect(a.end).to be_nil
    expect(a.for).to be_nil
    expect(a.send("-")).to be_nil
    expect(a.send("=")).to be_nil
    expect(a.send("with space")).to be_nil
  end

  it "allows all of the weird setter names to be called" do
    a = subject.new("bar", 456)

    a.FOO = "foo"
    expect(a.FOO).to eq("foo")

    a.send("123=", 789)
    expect(a.send("123")).to eq(789)

    a.Capitalized = true
    expect(a.Capitalized).to eq(true)

    a.cameLized = true
    expect(a.cameLized).to eq(true)

    a.⛔ = true
    expect(a.⛔).to eq(true)

    a.end = true
    expect(a.end).to eq(true)

    a.for = true
    expect(a.for).to eq(true)

    a.send("-=", true)
    expect(a.send("-")).to eq(true)

    a.send("==", true)
    expect(a.send("=")).to eq(true)

    a.send("with space=", true)
    expect(a.send("with space")).to eq(true)
  end

  it "throws an argument error when an invalid keyword is used" do
    expect { OptStruct.new(:class) }.to raise_error(ArgumentError)
    expect { OptStruct.new(:options) }.to raise_error(ArgumentError)
  end
end
