# Spot

### Table of Content
* [Commands](#commands)
* [Code Snippets](#code-snippets)
* [Links](#links)

## Commands
```bash
##
SPOT_TOKEN="change_here"
SPOT_ACCOUNT_ID="change_here"

curl -XGET -H "Authorization: bearer $SPOT_TOKEN" \
     "https://api.spotinst.io/aws/ec2/group?accountId=$SPOT_ACCOUNT_ID"

curl -XGET -H "Authorization: bearer $SPOT_TOKEN" \
     "https://api.spotinst.io/setup/account"



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
