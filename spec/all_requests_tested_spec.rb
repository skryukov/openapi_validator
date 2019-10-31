RSpec.describe OpenapiValidator do
  let(:validator) { OpenapiValidator.call("./spec/data/openapi_small.yml") }

  it "validates documentation against OpenAPI v3 schema" do
    result = validator.validate_documentation
    expect(result.errors).to eq([])
    expect(result).to be_valid
  end

  it "validates all request are tested" do
    validator
      .validate_request(path: "/pets", method: :get, code: 200)
      .validate_response(body: [{id: 6, name: "doggy"}], code: 201)

    result = validator.unvalidated_requests

    expect(result).to match_array([%w[/pets get 200], %w[/pets get default], %w[/pets post 200]])
  end

  it "validates all request are tested" do
    validator
      .validate_request(path: "/pets", method: :get, code: 200)
      .validate_response(body: [{id: 6, name: "doggy"}], code: 200)

    result = validator.unvalidated_requests

    expect(result).to match_array([%w[/pets get default], %w[/pets post 200]])
  end

  it "validates all request are tested" do
    validator
      .validate_request(path: "/pets", method: :get, code: 200)
      .validate_response(body: [{id: 6, name: "doggy"}], code: 200)
    validator
      .validate_request(path: "/pets", method: :get, code: 401)
      .validate_response(body: {code: 1, message: "error"}, code: 401)

    result = validator.unvalidated_requests

    expect(result).to match_array([%w[/pets post 200]])
  end

  it "validates all request are tested" do
    validator
      .validate_request(path: "/pets", method: :get, code: 200)
      .validate_response(body: [{id: 6, name: "doggy"}], code: 200)
    validator
      .validate_request(path: "/pets", method: :get, code: 401)
      .validate_response(body: {code: 1, message: "error"}, code: 401)
    validator
      .validate_request(path: "/pets", method: :post, code: 200)
      .validate_response(body: {id: 6, name: "doggy"}, code: 200)

    result = validator.unvalidated_requests

    expect(result).to be_empty
  end
end
