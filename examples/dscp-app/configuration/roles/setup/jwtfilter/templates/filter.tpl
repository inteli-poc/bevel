---
apiVersion: getambassador.io/v2
kind: Filter
metadata:
  name: jwt-filter
  namespace: [[ namespace ]]
spec:
  JWT:
    jwksURI: "[[ jwksUri ]]"
    validAlgorithms:
      - "RS256"
    audience: "[[ audience ]]"
    requireAudience: false
    leewayForExpiresAt: "120s"
    leewayForIssuedAt: "120s"
    injectRequestHeaders:
      - name: "X-Fixed-String"
        value: "Fixed String"
        # result will be "Fixed String"
      - name: "X-Token-String"
        value: "{{ .token.Raw }}"
        # result will be the token
      - name: "X-Token-H-Alg"
        value: "{{ .token.Header.alg }}"
        # result will be "none"
      - name: "X-Token-H-Typ"
        value: "{{ .token.Header.typ }}"
        # result will be "JWT"
      - name: "X-Token-H-Extra"
        value: "{{ .token.Header.extra }}"
        # result will be "so much"
      - name: "X-Token-C-Sub"
        value: "{{ .token.Claims.sub }}"
        # result will be "1234567890"
      - name: "X-Token-C-Name"
        value: "{{ .token.Claims.name }}"
        # result will be "John Doe"
      - name: "X-Token-C-Optional-Empty"
        value: "{{ .token.Claims.optional }}"
        # result will be "<no value>"; the header field will be set
        # even if the "optional" claim is not set in the JWT.
      - name: "X-Token-C-Optional-Unset"
        value: "{{ if hasKey .token.Claims \"optional\" | not }}{{ doNotSet }}{{ end }}{{ .token.Claims.optional }}"
        # Similar to "X-Token-C-Optional-Empty" above, but if the
        # "optional" claim is not set in the JWT, then the header
        # field won't be set either.
        #
        # Note that this does NOT remove/overwrite a client-supplied
        # header of the same name.  In order to distrust
        # client-supplied headers, you MUST use a Lua script to
        # remove the field before the Filter runs (see below).
      - name: "X-Token-C-Iat"
        value: "{{ .token.Claims.iat }}"
        # result will be "1.516239022e+09" (don't expect JSON numbers
        # to always be formatted the same as input; if you care about
        # that, specify the formatting; see the next example)
      - name: "X-Token-C-Iat-Decimal"
        value: "{{ printf \"%.0f\" .token.Claims.iat }}"
        # result will be "1516239022"
      - name: "X-Token-S"
        value: "{{ .token.Signature }}"
        # result will be "" (since "alg: none" was used in this example JWT)
      - name: "X-Authorization"
        value: "Authenticated {{ .token.Header.typ }}; sub={{ .token.Claims.sub }}; name={{ printf \"%q\" .token.Claims.name }}"
        # result will be: "Authenticated JWT; sub=1234567890; name="John Doe""
      - name: "X-UA"
        value: "{{ .httpRequestHeader.Get \"User-Agent\" }}"
        # result will be: "curl/7.66.0" or
        # "Mozilla/5.0 (X11; Linux x86_64; rv:69.0) Gecko/20100101 Firefox/69.0"
        # or whatever the requesting HTTP client is
    errorResponse:
      headers:
      - name: "Content-Type"
        value: "application/json"
      - name: "X-Correlation-ID"
        value: "{{ .httpRequestHeader.Get \"X-Correlation-ID\" }}"
      # Regarding the "altErrorMessage" below:
      #   ValidationErrorExpired = 1<<4 = 16
      # https://godoc.org/github.com/dgrijalva/jwt-go#StandardClaims
      bodyTemplate: |-
        {
            "errorMessage": {{ .message | json "    " }},
            {{- if .error.ValidationError }}
            "altErrorMessage": {{ if eq .error.ValidationError.Errors 16 }}"expired"{{ else }}"invalid"{{ end }},
            "errorCode": {{ .error.ValidationError.Errors | json "    "}},
            {{- end }}
            "httpStatus": "{{ .status_code }}",
            "requestId": {{ .request_id | json "    " }}
        }
---
apiVersion: getambassador.io/v2
kind: Module
metadata:
  name: ambassador
  namespace: default
spec:
  config:
    lua_scripts: |
      function envoy_on_request(request_handle)
        request_handle:headers():remove("x-token-c-optional-unset")
      end
