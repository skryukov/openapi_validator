RSpec.describe OpenapiValidator do
  let(:validator) { OpenapiValidator.call("./spec/data/required_params.yml") }

  it "raises error" do
    result = validator
      .validate_request(path: "/pets/{id}", method: :get, code: 200)
      .validate_response(body: {id: 6}, code: 200)

    expect(result.errors.first).to include("name")
    expect(result).to_not be_valid
  end
end
