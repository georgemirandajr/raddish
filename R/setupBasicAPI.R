# Create a Get call to an API
# Always refer to your specific API documentation
require(rstudioapi)

setupBasicAPI = function() {
  rstudioapi::insertText(
    "
# Base URL
url = ''

# Host (website domain)
hostName = ''

# Usually a public key (not encoded)
api_key = ''

# Secret key is usually encoded
secretKey = ''

res = httr::GET( url,
                 add_headers( Authorization = paste( 'Basic', secretKey ),
                              Host = hostName ),
                 query = list(
                   key = api_key, q = '',
                 ),
                 accept_json(),
                 content_type_json()
)

# rawToChar converts javascript objects (JSON) characters
api_data = fromJSON(
  rawToChar(
    res$content
  )
)
"
  )
}
