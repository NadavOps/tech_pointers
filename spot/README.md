# Spot

### Table of Content
* [Commands](#commands)
* [Code Snippets](#code-snippets)
* [Links](#links)

## Commands
```bash

```

## Code Snippets
```bash
# Get oauth token
saml_response_raw="paste_browser_saml_response_here"
saml_response_decoded=$(echo "$saml_response_raw" | base64 -d)
org_id="paste_org_id"
curl -XPOST "https://oauth.spotinst.io/samlToken?organizationId=$org_id" \
    -H "Content-Type: application/xml" \
    -d "$saml_response_decoded"
```

## Links
