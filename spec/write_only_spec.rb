RSpec.describe OpenapiValidator do

  let(:validator) { OpenapiValidator.call("./spec/data/write_only.yml") }

  it "ignores write_only attribute on get method" do
    result = validator
      .validate_request(path: "/pets", method: :get, code: 200)
      .validate_response(body: [{ id: 6 }], code: 200)

    expect(result.errors).to eq([])
    expect(result).to be_valid
  end
end
