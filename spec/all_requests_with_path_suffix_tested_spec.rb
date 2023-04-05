RSpec.describe OpenapiValidator do
  let(:validator) { OpenapiValidator.call("./spec/data/openapi_small_with_path_suffix.yml") }

  it "validates documentation against OpenAPI v3 schema" do
    result = validator.validate_documentation
    expect(result.errors).to eq([])
    expect(result).to be_valid
  end

  it "validates all request are tested" do
    validator
      .validate_request(path: "/pets.json", method: :get, code: 200)
      .validate_response(body: [{id: 6, name: "doggy"}], code: 201)

    result = validator.unvalidated_requests

    expect(result).to match_array([%w[/pets.json get 200], %w[/pets.json get default], %w[/pets.json post 200]])
  end

  it "validates all request are tested" do
    validator
      .validate_request(path: "/pets.json", method: :get, code: 200)
      .validate_response(body: [{id: 6, name: "doggy"}], code: 200)

    result = validator.unvalidated_requests

    expect(result).to match_array([%w[/pets.json get default], %w[/pets.json post 200]])
  end

  it "validates all request are tested" do
    validator
      .validate_request(path: "/pets.json", method: :get, code: 200)
      .validate_response(body: [{id: 6, name: "doggy"}], code: 200)
    validator
      .validate_request(path: "/pets.json", method: :get, code: 401)
      .validate_response(body: {code: 1, message: "error"}, code: 401)

    result = validator.unvalidated_requests

    expect(result).to match_array([%w[/pets.json post 200]])
  end

  it "validates all request are tested" do
    validator
      .validate_request(path: "/pets.json", method: :get, code: 200)
      .validate_response(body: [{id: 6, name: "doggy"}], code: 200)
    validator
      .validate_request(path: "/pets.json", method: :get, code: 401)
      .validate_response(body: {code: 1, message: "error"}, code: 401)
    validator
      .validate_request(path: "/pets.json", method: :post, code: 200)
      .validate_response(body: {id: 6, name: "doggy"}, code: 200)

    result = validator.unvalidated_requests

    expect(result).to be_empty
  end
end
