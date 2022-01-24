require 'net/http'
require "json"

def uri
  URI.parse("https://api.github.com/graphql")
end

QUERY_STRING = "query IntrospectionQuery {\n  __schema {\n    queryType {\n      name\n    }\n    mutationType {\n      name\n    }\n    subscriptionType {\n      name\n    }\n    types {\n      ...FullType\n    }\n    directives {\n      name\n      description\n      locations\n      args {\n        ...InputValue\n      }\n    }\n  }\n}\n\nfragment FullType on __Type {\n  kind\n  name\n  description\n  fields(includeDeprecated: true) {\n    name\n    description\n    args {\n      ...InputValue\n    }\n    type {\n      ...TypeRef\n    }\n    isDeprecated\n    deprecationReason\n  }\n  inputFields {\n    ...InputValue\n  }\n  interfaces {\n    ...TypeRef\n  }\n  enumValues(includeDeprecated: true) {\n    name\n    description\n    isDeprecated\n    deprecationReason\n  }\n  possibleTypes {\n    ...TypeRef\n  }\n}\n\nfragment InputValue on __InputValue {\n  name\n  description\n  type {\n    ...TypeRef\n  }\n  defaultValue\n}\n\nfragment TypeRef on __Type {\n  kind\n  name\n  ofType {\n    kind\n    name\n    ofType {\n      kind\n      name\n      ofType {\n        kind\n        name\n        ofType {\n          kind\n          name\n          ofType {\n            kind\n            name\n            ofType {\n              kind\n              name\n              ofType {\n                kind\n                name\n              }\n            }\n          }\n        }\n      }\n    }\n  }\n}"

def headers(token)
  {
    "Authorization" => "bearer #{token}"
  }
end

def execute(token, operation_name: nil, variables: {}, context: {})
  request = Net::HTTP::Post.new(uri.request_uri)

  request.basic_auth(uri.user, uri.password) if uri.user || uri.password

  request["Accept"] = "application/json"
  request["Content-Type"] = "application/json"
  headers(token).each { |name, value| request[name] = value }

  body = {}
  body["query"] = QUERY_STRING
  body["variables"] = variables if variables.any?
  body["operationName"] = operation_name if operation_name
  request.body = JSON.generate(body)

  response = connection.request(request)
  case response
  when Net::HTTPOK, Net::HTTPBadRequest
    JSON.parse(response.body)
  else
    { "errors" => [{ "message" => "#{response.code} #{response.message}" }] }
  end
end

# Public: Extension point for subclasses to customize the Net:HTTP client
#
# Returns a Net::HTTP object
def connection
  Net::HTTP.new(uri.host, uri.port).tap do |client|
    client.use_ssl = uri.scheme == "https"
  end
end

result = execute(
  ARGV[0],
  operation_name: "IntrospectionQuery"
)

puts result
