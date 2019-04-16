RSpec.describe OpenapiValidator do
  it "has a version number" do
    expect(OpenapiValidator::VERSION).not_to be nil
  end

  let(:validator) { OpenapiValidator.call("./spec/data/openapi.yml") }

  it "validates documentation against OpenAPI v3 schema" do
    result = validator.validate_documentation
    expect(result.errors).to eq([])
    expect(result).to be_valid
  end

  context "when bad schema provided" do
    let(:validator) { OpenapiValidator.call("./spec/data/bad_openapi.yml") }

    it "validates documentation against OpenAPI v3 schema" do
      result = validator.validate_documentation

      expect(result.errors.first).to include("paths")
      expect(result).to_not be_valid
    end
  end

  context "when additional schema provided" do
    let(:validator) do
      OpenapiValidator.call("./spec/data/openapi.yml", additional_schemas: ["./spec/data/additional_schema.yml"])
    end

    it "validates documentation against additional schemas" do
      result = validator.validate_documentation

      expect(result.errors.first).to include("custom_key")
    end
  end

  let(:request) do
    {
      path: "/path?q=qwerty",
      method: :post,
      headers: { "X-User-Id": 12345 },
      body: { my: "params" },
    }
  end

  let(:response) do
    {
      code: 200,
      media_type: "application/json",
      headers: { "X-User-Id": 12345 },
      body: { my: "params" },
    }
  end

  it "validates that request is documented" do
    result = validator.validate_request(
      path: "/pets?limit=10",
      method: :get,
      media_type: "application/json",
      code: 200,
    # body: {},
    # headers: {},
    )

    expect(result.errors).to eq([])
    expect(result).to be_valid
  end

  it "validates that request is documented" do
    result = validator.validate_request(
      path: "/pets?limit=10",
      method: :get,
      media_type: "application/json",
      code: 500,
    # body: {},
    # headers: {},
    )

    expect(result.errors).to eq([])
    expect(result).to be_valid
  end

  it "validates that request is documented" do
    result = validator.validate_request(
      path: "/pets/{id}",
      method: :delete,
      media_type: "application/json",
      code: 401,
    # body: {},
    # headers: {},
    )

    expect(result.errors).to eq([])
    expect(result).to be_valid
  end

  it "returns error when request is not documented" do
    result = validator.validate_request(
      path: "/bad_path?limit=10",
      method: :get,
      media_type: "application/json",
      code: 200,
    # body: {},
    # headers: {},
    )

    expect(result.errors).to eq(["OpenAPI documentation does not have a documented path for /bad_path"])
    expect(result).not_to be_valid
  end

  it "returns error when request is not documented" do
    result = validator.validate_request(
      path: "/pets?limit=10",
      method: :delete,
      media_type: "application/json",
      code: 200,
    # body: {},
    # headers: {},
    )

    expect(result.errors).to eq(["OpenAPI documentation does not have a documented path for DELETE /pets"])
    expect(result).not_to be_valid
  end

  it "returns error when request is not documented" do
    result = validator.validate_request(
      path: "/pets?limit=10",
      method: :get,
      media_type: "application/xml",
      code: 200,
    # body: {},
    # headers: {},
    )

    expect(result.errors).to eq(["OpenAPI documentation does not have a documented response for application/xml media-type at path GET /pets"])
    expect(result).not_to be_valid
  end

  it "returns error when request is not documented" do
    result = validator.validate_request(
      path: "/pets/{id}",
      method: :delete,
      media_type: "application/json",
      code: 444,
    # body: {},
    # headers: {},
    )

    expect(result.errors).to eq(["OpenAPI documentation does not have a documented response for code 444 at path DELETE /pets/{id}"])
    expect(result).not_to be_valid
  end

  xit "validates request headers"
  xit "validates request body params"
  xit "validates request query params"

  xit "validates response headers"
  xit "validates response media type"

  it "validates response code" do
    result = validator.validate_request(
      path: "/pets?limit=10",
      method: :get,
      media_type: "application/json",
      code: 200,
    # body: {},
    # headers: {},
    ).validate_response(body: [{ id: 6, name: "doggy" }], code: 200)

    expect(result.errors).to eq([])
    expect(result).to be_valid
  end

  it "validates response code" do
    result = validator.validate_request(
      path: "/pets?limit=10",
      method: :get,
      media_type: "application/json",
      code: 200,
    # body: {},
    # headers: {},
    ).validate_response(body: [{ id: 6, name: "doggy" }], code: 201)

    expect(result.errors.first).to include("Expected 200 got 201")
    expect(result).not_to be_valid
  end

  it "validates response body" do
    result = validator.validate_request(
      path: "/pets?limit=10",
      method: :get,
      media_type: "application/json",
      code: 200,
    # body: {},
    # headers: {},
    ).validate_response(body: [{ id: 6, name: "doggy" }], code: 200)

    expect(result.errors).to eq([])
    expect(result).to be_valid
  end

  it "validates response body with $ref as a response" do
    result = validator.validate_request(
      path: "/pets/{id}",
      method: :delete,
      media_type: "application/json",
      code: 401,
    ).validate_response(body: { code: 1, message: "Error message" }, code: 401)

    expect(result.errors).to eq([])
    expect(result).to be_valid
  end

  it "validates response body" do
    result = validator.validate_request(
      path: "/pets?limit=10",
      method: :get,
      media_type: "application/json",
      code: 200,
    # body: {},
    # headers: {},
    ).validate_response(body: [{ id: 6, name: nil }], code: 200)

    expect(result.errors).to eq([])
    expect(result).to be_valid
  end

  it "validates response body" do
    result = validator.validate_request(
      path: "/pets?limit=10",
      method: :get,
      media_type: "application/json",
      code: 200,
    ).validate_response(body: [{ id: 123 }], code: 200)

    expect(result.errors.first).to include("did not contain a required property of 'name'")
    expect(result).not_to be_valid
  end
end
